# frozen_string_literal: true

RSpec.describe TechnumaHelloWorld do
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
  it "has a version number" do
    expect(TechnumaHelloWorld::VERSION).not_to be nil
  end
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
