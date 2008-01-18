# require this in your .siterc and it'll re-require your .siterc
# on every #call to your site, making development much easier!

site.instance_eval {

  alias call_without_reload call unless defined?call_without_reload
  def call_with_reload *args
    load_siterc
    call_without_reload *args
  end
  alias call call_with_reload

}
