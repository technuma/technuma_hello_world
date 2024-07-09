# frozen_string_literal: true

RSpec.describe TechnumaHelloWorld do
  it "has a version number" do
    expect(TechnumaHelloWorld::VERSION).not_to be nil
  end

  describe "simple Post Model" do
    before do
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Schema.define do
        create_table :posts, force: true do |t|
          t.integer :legacy_comments_count, default: 0
          t.datetime :created_at, precision: 0
          t.datetime :updated_at, precision: 4
        end

        create_table :comments, force: true do |t|
          t.integer :post_id
        end
      end

      class Post < ActiveRecord::Base
        has_many :comments
        alias_attribute :comments_count, :legacy_comments_count
      end

      class Comment < ActiveRecord::Base
        belongs_to :post
      end
    end

    describe "where with comparison operator key" do
      let!(:post1) { Post.create! }
      let!(:post2) { Post.create! }
      let!(:post3) { Post.create! }
      let(:posts) { Post.order(:id) }

      it "correctly applies comparison operators in where clauses" do
        expect(posts.where("id >": 1).pluck(:id)).to eq([2, 3])
        expect(posts.where("id >=": 1).pluck(:id)).to eq([1, 2, 3])
        expect(posts.where("id <": 2).pluck(:id)).to eq([1])
        expect(posts.where("id <=": 2).pluck(:id)).to eq([1, 2])
      end
    end

    describe "alias_attribute :comments_count, :legacy_comments_count" do
      let!(:post1) { Post.create!(comments_count: 4) }
      let!(:post2) { Post.create!(comments_count: 5) }
      let!(:post3) { Post.create!(comments_count: 6) }

      it "allows querying using the aliased attribute name 'comments_count'" do
        expect(Post.where("comments_count >=": 5).count).to eq(2)
        expect(Post.where("comments_count >": 5).count).to eq(1)
        expect(Post.where("comments_count <=": 5).count).to eq(2)
        expect(Post.where("comments_count <": 5).count).to eq(1)
      end
    end

    describe "unscoping table name qualified column" do
      let(:post1) { Post.create!(comments_count: 1) }
      let!(:comment1) { post1.comments.create! }
      let(:post2) { Post.create!(comments_count: 1) }
      let!(:comment2) { post2.comments.create! }

      it "correctly unscopes table name qualified column" do
        comments = Comment.joins(:post).where("posts.id <=": post1)
        expect(comments).to eq([comment1])

        comments = comments.where("id >=": 2)
        expect(comments).to be_empty

        comments = comments.unscope(where: :"posts.id")
        expect(comments).to eq([comment2])
      end
    end

    describe "#merge" do
      let!(:post1) { Post.create! }
      let!(:post2) { Post.create! }

      it "merges with a post condition" do
        expect(Post.where("id <=": 2).merge(Post.where(id: 2))).to eq([post2])
      end
    end

    describe "references detection" do
      let(:post) { Post.create!(comments_count: 1) }
      let!(:comment) { post.comments.create! }

      it "correctly adds references when using string or hash conditions" do
        expect(Post.eager_load(:comments).where("comments.id >= ?", 0).references_values).to eq([])
        expect(Post.eager_load(:comments).where("comments.id >=": 0).references_values).to eq(["comments"])
      end
    end

    # https://github.com/rails/rails/pull/39863/files#diff-fba6d35ef65b69650470b26fbf8e945446b6bb92c543e944015908a9fe200d62R101-R106
    describe "datetime precision" do
      let(:date) { ::Time.utc(2014, 8, 17, 12, 30, 0, 999_999) }
      let!(:post) { Post.create!(created_at: date, updated_at: date) }

      it "formats datetime according to precision" do
        expect(Post.find_by("created_at >= ?", date)).to be_nil
        expect(Post.where("updated_at >= ?", date).count).to eq(0)
        expect(Post.find_by("created_at >=": date)).to be_truthy
        expect(Post.where("updated_at >=": date).count).to eq(1)
      end
    end
  end

  # https://github.com/rails/rails/pull/39863/files#diff-12d007e9c2419aa48cfd2003590590870871d40704fe22cb85a2bf9d56e0b307R95-R100
  describe "time precision" do
    before do
      ActiveRecord::Schema.define do
        create_table :foos, force: true do |t|
          t.time :start, precision: 0
          t.time :finish, precision: 4
        end
      end
      class Foo < ActiveRecord::Base; end
    end

    let(:time) { Time.utc(2000, 1, 1, 12, 30, 0, 999_999) }
    let!(:foo) { Foo.create!(start: time, finish: time) }

    it "handles time precision correctly" do
      expect(Foo.find_by("start >= ?", time)).to be_nil
      expect(Foo.where("finish >= ?", time).count).to eq(0)

      expect(Foo.find_by("start >=": time)).to be_truthy
      expect(Foo.where("finish >=": time).count).to eq(1)
    end
  end
end
