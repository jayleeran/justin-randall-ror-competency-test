require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "gets article categories" do
    assert_equal ["Category1", "Category2"], Article.article_categories
  end
  
  test "can be scoped by category" do
    assert_equal Article.for_category("Category1"), Article.where(:category=>"Category1")
  end

  test 'valid article' do
    article = articles(:user_one)
    assert article.valid?
  end

  test 'invalid without title' do
    article = articles(:user_one)
    article.title = nil
    refute article.valid?, 'article is valid without a title'
    assert_not_nil article.errors[:title], 'no validation error for title present'
  end

  test 'invalid without content' do
    article = articles(:user_one)
    article.content = nil
    refute article.valid?, 'article is valid without a content'
    assert_not_nil article.errors[:content], 'no validation error for content present'
  end

  test 'invalid without category' do
    article = articles(:user_one)
    article.category = nil
    refute article.valid?, 'article is valid without a category'
    assert_not_nil article.errors[:category], 'no validation error for category present'
  end

  test 'invalid without user' do
    article = articles(:user_one)
    article.user_id = nil
    refute article.valid?, 'article is valid without a user'
    assert_not_nil article.errors[:user_id], 'no validation error for user present'
  end
end
