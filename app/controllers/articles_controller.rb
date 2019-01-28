class ArticlesController < ApplicationController
  before_action :check_creator_or_admin, only: [:edit, :update, :destroy]
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  access all: [:index, :show], [:editor, :admin] => :all

  skip_before_action :authenticate_user!, only: [:index]

  # GET /articles
  def index
    @articles = Article.all
  end

  # GET /articles/1
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  def create
    @article = Article.new(article_params)
    @article.user = current_user
    if @article.save
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /articles/1
  def update
    if @article.update(article_params)
      redirect_to @article, notice: 'Article was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /articles/1
  def destroy
    @article.destroy
    redirect_to articles_url, notice: 'Article was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(:title, :content, :category, :user_id)
    end
    
    def check_creator_or_admin
      @article = Article.find(params[:id])
      forbidden! unless (current_user.has_role?(:admin) || @article.user == current_user)
    end
end
