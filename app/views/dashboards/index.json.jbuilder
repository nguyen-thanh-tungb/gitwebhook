json.array!(@dashboards) do |dashboard|
  json.extract! dashboard, :id, :data
  json.url dashboard_url(dashboard, format: :json)
end
