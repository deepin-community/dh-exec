## -*- shell-script -*-

load "test.lib"

setup () {
        dh_subst_test_empty_var=""
        dh_subst_test_var="foo"

        unset dh_subst_test_novar
        export dh_subst_test_var
        export dh_subst_test_empty_var
}

run_dh_exec_subst () {
        run_dh_exec src/dh-exec-subst <<EOF
dh_subst_test_var   = \${dh_subst_test_var}
dh_subst_test_novar = \${dh_subst_test_novar}
dh_subst_test_empty_var = \${dh_subst_test_empty_var}
dh_subst_test_var_env   = \${env:dh_subst_test_var}
dh_subst_test_empty_var_env = \${env:dh_subst_test_empty_var}
EOF
}

run_dh_exec_subst_err () {
        run_dh_exec src/dh-exec-subst <<EOF
dh_subst_test_var   = \${dh_subst_test_var}
dh_subst_test_novar = \${env:dh_subst_test_novar}
EOF
}

@test "subst-env: defined variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_var   = foo'
}

@test "subst-env: undefined variable is not expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_novar = ${dh_subst_test_novar}'
}

@test "subst-env: defined but empty variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_empty_var = '
}

@test "subst-env: defined env:variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_var_env   = foo'
}

@test "subst-env: undefined env:variable causes error" {
        run_dh_exec_subst_err

        expect_error 'Cannot expand "${env:dh_subst_test_novar}" as the ENV variable "dh_subst_test_novar" is unset.'
}

@test "subst-env: defined but empty env:variable gets expanded" {
        run_dh_exec_subst

        expect_output 'dh_subst_test_empty_var_env = '
}
