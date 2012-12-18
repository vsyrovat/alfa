# Eval in actual application's context (CliApplication, WebApplication or other)

config[:project_root] = PROJECT_ROOT
config[:document_root] = DOCUMENT_ROOT
config[:db][:main] = {:instance => DB::Main, :maintain => true}
