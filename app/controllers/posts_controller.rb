class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    respond_to do |format|
      format.html
      format.csv { send_data Post.to_csv, filename: "posts-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end

  def import
    if params[:file].nil?
      redirect_to request.referer, notice: 'No file added'
    elsif params[:file].content_type != 'text/csv'
      redirect_to request.referer, notice: 'Only CSV files allowed'
    else
      filename = "#{SecureRandom.uuid}.csv"
      file_path = Rails.root.join('tmp', 'csv_uploads', filename)
  
      FileUtils.mkdir_p(File.dirname(file_path))
  
      File.open(file_path, 'wb') do |file|
        file.write(params[:file].read)
      end
  
      CsvJob.perform_async(file_path.to_s)
      redirect_to request.referer, notice: 'Import started...'
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :author, :likes, :comments)
    end
end
