require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  describe "homepage" do
    test "sees homepage" do
      get root_path
      assert_select "h1", "Home"
    end
  end

  ################################################################################
  # Nav bar
  ################################################################################
  describe "nav" do
    test "sees nav" do
      get root_path
      assert_select "nav" do
        assert_select "a", "Home"
      end
    end

    test "sees link to articles index in nav" do
      get root_path
      assert_select "nav" do
        assert_select "li", "Articles"
      end
    end

    test "sees login in nav if not authenticated" do
      get root_path
      assert_select "nav" do
        assert_select "li", "Login"
      end
    end

    test "sees edit profile and logout in nav if authenticated" do
      login_as_user do
        get root_path
        assert_select "nav" do
          assert_select "li", "Edit profile"
          assert_select "li", "Logout"
        end
      end
    end
  end

  ################################################################################
  # Guest (unauthenticated)
  ################################################################################
  describe "as guest" do
    test "can see homepage with first 3 articles from each category" do
      get root_path
      categories = Article.article_categories
      categories.each do |category|
        assert_select "h2", category
        assert_select "table##{category.parameterize.underscore}" do
          article_count = Article.for_category(category).count
          expected_showing_articles = (article_count > 3) ? 3 : article_count
          assert_select "tr.article", expected_showing_articles
        end
      end
    end

    test "can see article index page" do
      get articles_path
      assert_response :success
    end
    
    test "are sent to login/signup page if they want to see article show page" do
      get article_path(Article.first)
      assert_redirected_to new_user_session_path
    end

    test "can signup" do
      get new_user_registration_path
      assert_select "h2", "Sign up"
      assert_difference('User.count') do
        post '/users', params: { user: { email: "test@test.com", password: "testpass" } }
      end
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
    
    test "can login" do
      get new_user_session_path
      assert_select "h2", "Log in"
      login_as_user do
        get root_path
        assert_select "nav" do
          assert_select "li", "Logout"
        end
      end
    end
  end

  ################################################################################
  # User (basic authenticated)
  ################################################################################
  describe "as user" do
    before do
      login_as_user
    end
    after do
      sign_out(users :user)
    end

    test "can see homepage with first 3 articles from each category" do
      get root_path
      categories = Article.article_categories
      categories.each do |category|
        assert_select "h2", category
        assert_select "table##{category.parameterize.underscore}" do
          article_count = Article.for_category(category).count
          expected_showing_articles = (article_count > 3) ? 3 : article_count
          assert_select "tr.article", expected_showing_articles
        end
      end
    end

    test "can see article index page" do
      get articles_path
      assert_response :success
    end

    test "can see article show pages" do
      get article_path(Article.first)
      assert_response :success
    end

    test "can logout" do
      get root_path
      delete destroy_user_session_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "nav" do
        assert_select "li", "Login"
      end
    end

    test "can not create articles" do
      get new_article_path
      assert_response 302
      flash[:notice].must_equal "Permission Denied"    
    end
  end

  ################################################################################
  # Editor
  ################################################################################
  describe "as editor" do
    before do
      login_as_editor
    end
    after do
      sign_out(users :editor)
    end

    test "can see homepage with first 3 articles from each category" do
      get root_path
      categories = Article.article_categories
      categories.each do |category|
        assert_select "h2", category
        assert_select "table##{category.parameterize.underscore}" do
          article_count = Article.for_category(category).count
          expected_showing_articles = (article_count > 3) ? 3 : article_count
          assert_select "tr.article", expected_showing_articles
        end
      end
    end

    test "can see article index page" do
      get articles_path
      assert_response :success
    end

    test "can see article show pages" do
      get article_path(Article.first)
      assert_response :success
    end

    test "can logout" do
      get root_path
      delete destroy_user_session_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "nav" do
        assert_select "li", "Login"
      end
    end

    test "can create articles" do
      get new_article_path
      assert_difference('Article.count') do
        post articles_path, params: { article: { title: "New editor article", content: "New editor article content", category: "Category2" } }
      end
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end

    test "can delete articles that they created" do
      editor_article = Article.where(user_id: users(:editor).id).first
      delete article_path(editor_article)
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully destroyed."
    end

    test "cannot delete articles that they didn't create" do
      admin_article = Article.where(user_id: users(:admin).id).first
      delete article_path(admin_article)
      flash[:notice].must_equal "Permission Denied"
    end

    test "can edit articles that they created" do
      editor_article = Article.where(user_id: users(:editor).id).first
      get edit_article_path(editor_article)
      patch article_path(editor_article), params: { article: { title: "Changed editor article title" } }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully updated."
    end

    test "cannot edit articles that they didn't create" do
      admin_article = Article.where(user_id: users(:admin).id).first
      get edit_article_path(admin_article)
      flash[:notice].must_equal "Permission Denied"
    end

    test "cannot create users" do
      get admin_new_users_path
      flash[:notice].must_equal "Permission Denied"
    end

    test "can edit users" do
      user = users(:user)
      get admin_edit_user_path(user)
      flash[:notice].must_equal "Permission Denied"
    end
  end

  ################################################################################
  # Admin
  ################################################################################
  describe "as admin" do
    before do
      login_as_admin
    end
    after do
      sign_out(users :admin)
    end

    test "can see homepage with first 3 articles from each category" do
      get root_path
      categories = Article.article_categories
      categories.each do |category|
        assert_select "h2", category
        assert_select "table##{category.parameterize.underscore}" do
          article_count = Article.for_category(category).count
          expected_showing_articles = (article_count > 3) ? 3 : article_count
          assert_select "tr.article", expected_showing_articles
        end
      end
    end

    test "can see article index page" do
      get articles_path
      assert_response :success
    end

    test "can see article show pages" do
      get article_path(Article.first)
      assert_response :success
    end

    test "can logout" do
      get root_path
      delete destroy_user_session_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "nav" do
        assert_select "li", "Login"
      end
    end

    test "can create articles" do
      get new_article_path
      assert_difference('Article.count') do
        post articles_path, params: { article: { title: "New admin article", content: "New admin article content", category: "Category2" } }
      end
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end

    test "can delete articles that they created" do
      admin_article = Article.where(user_id: users(:admin).id).first
      delete article_path(admin_article)
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully destroyed."
    end

    test "can delete articles that they didn't create" do
      non_admin_article = Article.where.not(user_id: users(:admin).id).first
      get edit_article_path(non_admin_article)
      patch article_path(non_admin_article), params: { article: { title: "Changed non-admin article title" } }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully updated."
    end

    test "can edit articles that they created" do
      admin_article = Article.where(user_id: users(:admin).id).first
      get edit_article_path(admin_article)
      patch article_path(admin_article), params: { article: { title: "Changed admin article title" } }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully updated."
    end

    test "can edit articles that they didn't create" do
      non_admin_article = Article.where.not(user_id: users(:admin).id).first
      get edit_article_path(non_admin_article)
      patch article_path(non_admin_article), params: { article: { title: "Changed non-admin article title" } }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "Article was successfully updated."
    end

    test "can create users and set roles" do
      get admin_new_users_path
      assert_difference('User.count') do
        post admin_create_users_path, params: { user: { email: "test@test.com", password: "testpass1", password_confirmation: "testpass1", roles: :editor} }
      end
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end

    test "can edit users and change roles" do
      user = users(:user)
      get admin_edit_user_path(user)
      assert_difference('User.role_editors.count') do
        patch admin_update_user_path(user), params: { user: { email: "different@test.com", role: :editor } }
      end
      assert_response :redirect
      follow_redirect!
      assert_response :success
      flash[:notice].must_equal "User was successfully updated."
    end
  end
end
