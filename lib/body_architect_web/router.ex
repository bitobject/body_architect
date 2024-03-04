defmodule BodyArchitectWeb.Router do
  use BodyArchitectWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BodyArchitectWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BodyArchitectWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/workouts", WorkoutLive.Index, :index
    live "/workouts/new", WorkoutLive.Index, :new
    live "/workouts/:id/edit", WorkoutLive.Index, :edit

    live "/workouts/calendar", WorkoutLive.Calendar, :index
    live "/workouts/calendar/:date", WorkoutLive.Calendar, :show_date

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
end
