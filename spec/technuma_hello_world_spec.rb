# frozen_string_literal: true

RSpec.describe TechnumaHelloWorld do
  it "has a version number" do
    expect(TechnumaHelloWorld::VERSION).not_to be nil
  end

  describe "simple Post Model" do
    before do
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Schema.define do
        create_table :posts, force: true do |t|
          t.datetime :created_at, precision: 0
          t.datetime :updated_at, precision: 4
        end

        create_table :comments, force: true do |t|
          t.integer :post_id
        end
      end
      class Post < ActiveRecord::Base
        has_many :comments
      end

      class Comment < ActiveRecord::Base
        belongs_to :post
      end
    end

    # https://github.com/rails/rails/pull/39863/files#diff-1721af6d2f906e7e5eec9cac9a7707cd051c1a1f5ffb1b38c69a6c5a52ae4e9aR318-R326
    describe "exists with large number" do
      let!(:post) { Post.create! }

      it "checks post existence with large number conditions" do
        Post.create!
        expect(Post.where("id >": -9_223_372_036_854_775_809).exists?).to be true
        expect(Post.where("id >=": -9_223_372_036_854_775_809).exists?).to be true
        expect(Post.where("id <": 9_223_372_036_854_775_808).exists?).to be true
        expect(Post.where("id <=": 9_223_372_036_854_775_808).exists?).to be true

        expect(Post.where("id >": 9_223_372_036_854_775_808).exists?).to be false
        expect(Post.where("id >=": 9_223_372_036_854_775_808).exists?).to be false
        expect(Post.where("id <": -9_223_372_036_854_775_809).exists?).to be false
        expect(Post.where("id <=": -9_223_372_036_854_775_809).exists?).to be false
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
end
