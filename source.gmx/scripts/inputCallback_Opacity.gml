if (!global.input_bool)
    exit;

var alpha = real(global.input_string);
if (alpha >= 0 && alpha <= 1)
{
    global.window_alpha = alpha;
    window_set_alpha(global.window_alpha);
}

