class MovementsController < ApplicationController
  def index; end

  def show; end

  def new
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.build
  end

  def create
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.build(movement_params)
    @movement.author_id = current_user.id
    if @movement.save
      redirect_to user_group_path(current_user, @group), notice: 'Movement created sucessfully'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy
    @group = current_user.groups.find(params[:group_id])
    @movement = @group.movements.find(params[:id])
    @movement.destroy
    redirect_to user_group_path(current_user, @group)
  end

  private

  def movement_params
    params.require(:movement).permit(:name, :amount)
  end
end
