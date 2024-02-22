class GroupsController < ApplicationController
  def index
    # @groups = Group.all
    @groups = Group
      .select('groups.*, COALESCE(SUM(movements.amount), 0) as movements_sum')
      .left_joins(:movements)
      .group('groups.id')
  end

  def show
    @group = current_user.groups.find(params[:id])
    @movements = @group.movements.order(created_at: :desc)
  end

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

  def destroy
    @group = current_user.groups.find(params[:id])
    @group.destroy
    redirect_to authenticated_root_path, notice: 'Group was sucessfuly deleted'
  end

  private

  def group_params
    params.require(:group).permit(:name, :icon)
  end
end
