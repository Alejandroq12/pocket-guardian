class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def show; end

  def new
    @group = current_user.groups.build
  end

  def create
    @group = current_user.groups.build(group_params)
    if @group.save
      redirect_to user_groups_path(current_user), notice: 'Group was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def group_params
    params.require(:group).permit(:name, :icon)
  end
end
