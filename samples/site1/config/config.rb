# Eval in actual application's context (CliApplication, WebApplication or other)

config[:project_root] = PROJECT_ROOT
config[:document_root] = DOCUMENT_ROOT
config[:db][:main] = {
    :instance => DB::Main,
    :path => File.join(PROJECT_ROOT, 'db/main'), # require both instance and path
    :maintain => true,
}
config[:groups] = Project::GROUPS
config[:templates_priority] = [:haml]
