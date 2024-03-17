defmodule BodyArchitectWeb.Router do
  use BodyArchitectWeb, :router

  import BodyArchitectWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BodyArchitectWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BodyArchitectWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:body_architect, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BodyArchitectWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BodyArchitectWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BodyArchitectWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BodyArchitectWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BodyArchitectWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/", BodyArchitectWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BodyArchitectWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/workouts", WorkoutLive.Index, :index
      live "/workouts/new", WorkoutLive.Index, :new
      live "/workouts/:id/edit", WorkoutLive.Index, :edit

      live "/workouts/:id", WorkoutLive.Show, :show
      live "/workouts/:id/exercises/:exercise_id/sets/new", WorkoutLive.Show, :add_set
      live "/workouts/:id/sets/new", WorkoutLive.Show, :new_set
      live "/workouts/:id/sets/:set_id/edit", WorkoutLive.Show, :edit_set
      live "/workouts/:id/show/edit", WorkoutLive.Show, :edit

      live "/exercises", ExerciseLive.Index, :index
      live "/exercises/new", ExerciseLive.Index, :new
      live "/exercises/:id/edit", ExerciseLive.Index, :edit

      live "/exercises/:id", ExerciseLive.Show, :show
      live "/exercises/:id/show/edit", ExerciseLive.Show, :edit

      live "/sets", SetLive.Index, :index
      live "/sets/new", SetLive.Index, :new
      live "/sets/:id/edit", SetLive.Index, :edit

      live "/sets/:id", SetLive.Show, :show
      live "/sets/:id/show/edit", SetLive.Show, :edit

      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Index, :new
      live "/users/:id/edit", UserLive.Index, :edit

      live "/users/:id", UserLive.Show, :show
      live "/users/:id/show/edit", UserLive.Show, :edit

      live "/", WorkoutLive.Calendar, :index
      live "/new_workout/:date", WorkoutLive.Calendar, :new_workout
      live "/:date", WorkoutLive.Calendar, :show_date
    end
  end
end
