reset!(env::ALEPtr) = reset_game(env)
step!(env::ALEPtr, action::Integer) = act(env, action)
finished(env::ALEPtr) = game_over(env)

"""
`function time_steps(env::ALEPtr, num_eps::Int) where T`

run through num_eps eps, recording the time taken for each step and
how many steps were made. Doesn't time the `reset!` or the first step of each
episode (since higher chance that it's slower/faster than the rest, and we want
to compare the average time taken for each step as fairly as possible)
"""
function time_steps(env::ALEPtr, num_eps::Int)
    t = 0.0
    steps = 0
    actionset = getMinimalActionSet(env)
    for i in 1:num_eps
        reset!(env)
        step!(env, rand(actionset)) # ignore the first step - it might be slow?
        t += (@elapsed steps += epstep(env, actionset))
    end
    steps, t
end

"""
Steps through an episode until it's `done`
assumes env has been `reset!`
"""
function epstep(env::ALEPtr, actionset)
    steps = 0
    while !finished(env)
        steps += 1
        r = step!(env, rand(actionset))
    end
    steps
end

@testset "speed" begin
    ale = ALE_new()
    roms = ["pong", "ms_pacman"]
    num_eps = 10
    for rom in roms
        loadrom(ale, rom)
        steps, t = time_steps(ale, num_eps)
        @info "rom: $rom num_eps: $num_eps t: $t steps: $steps"
        @info "microsecs/step (lower is better): $(t*1e6/steps)"
        @info "------------------------------"
    end
    ALE_del(ale)
end
