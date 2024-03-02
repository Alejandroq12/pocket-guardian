class MovementsController < ApplicationController
  def index; end

  def show; end

  def new
    if params[:group_id]
      @group = current_user.groups.find(params[:group_id])
      @movement = @group.movements.build
    else
      @movement = Movement.new
      @groups = current_user.groups
    end
  end

  def create
    if params[:group_id]
      # Assign the group from the parameter if available
      @group = current_user.groups.find(params[:group_id])
      @movement = @group.movements.build(movement_params)
    else
      # This is for the scenario where a group is selected from a dropdown
      @movement = current_user.movements.build(movement_params)
    end

    @movement.author_id = current_user.id

    if @movement.save
      # Use the associated group for redirection, if present
      redirect_to @group ? user_group_path(current_user, @group) : authenticated_root_path,
                  notice: 'Movement created successfully'
    else
      # Reload groups for the form in case of failure and maintain group context if present
      @groups = current_user.groups
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
    params.require(:movement).permit(:name, :amount, :group_id)
  end
end
