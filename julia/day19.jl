test_input = """
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"""

input = read("inputs/input_day19.txt", String)

regex = r"Blueprint \d\d?: Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian."

input = map(filter(!isempty, split(input, "\n"))) do input
    input = match(regex, input).captures
    input = parse.(Int, input)
end

struct Blueprint
    ore_robot_ore_cost::Int
    clay_robot_ore_cost::Int
    obsidian_robot_ore_cost::Int
    obsidian_robot_clay_cost::Int
    geode_robot_ore_cost::Int
    geode_robot_obsidian_cost::Int
end

Blueprint(input::Vector{Int}) = Blueprint(input...)

blueprints = Blueprint.(input)

struct RobotState
    minutes::Int
    ore::Int
    clay::Int
    obsidian::Int
    geode::Int
    ore_robots::Int
    clay_robots::Int
    obsidian_robots::Int
    geode_robots::Int
end

struct RobotStateTimeless
    ore::Int
    clay::Int
    obsidian::Int
    geode::Int
    ore_robots::Int
    clay_robots::Int
    obsidian_robots::Int
    geode_robots::Int
end

function RobotStateTimeless(; ore=0, clay=0, obsidian=0, geode=0, ore_robots=1, clay_robots=0, obsidian_robots=0, geode_robots=0)
    RobotStateTimeless(ore, clay, obsidian, geode, ore_robots, clay_robots, obsidian_robots, geode_robots)
end

function RobotStateTimeless(state::RobotState)
    RobotStateTimeless(
        state.ore,
        state.clay,
        state.obsidian,
        state.geode,
        state.ore_robots,
        state.clay_robots,
        state.obsidian_robots,
        state.geode_robots,
    )
end


import Base: isless

isless(a::RobotState, b::RobotState) = a.geode < b.geode || a.minutes < b.minutes

function RobotState(; minutes=32, ore=0, clay=0, obsidian=0, geode=0, ore_robots=1, clay_robots=0, obsidian_robots=0, geode_robots=0)
    RobotState(minutes, ore, clay, obsidian, geode, ore_robots, clay_robots, obsidian_robots, geode_robots)
end

function is_buildable(blueprint::Blueprint, state::RobotState, robot::Symbol)
    if robot == :ore
        state.ore >= blueprint.ore_robot_ore_cost
    elseif robot == :clay
        state.ore >= blueprint.clay_robot_ore_cost
    elseif robot == :obsidian
        state.ore >= blueprint.obsidian_robot_ore_cost && state.clay >= blueprint.obsidian_robot_clay_cost
    elseif robot == :geode
        state.ore >= blueprint.geode_robot_ore_cost && state.obsidian >= blueprint.geode_robot_obsidian_cost
    end
end

function next(blueprint::Blueprint, state::RobotState, robot::Symbol)
    if robot == :ore
        RobotState(
            state.minutes - 1,
            state.ore - blueprint.ore_robot_ore_cost + state.ore_robots,
            state.clay + state.clay_robots,
            state.obsidian + state.obsidian_robots,
            state.geode + state.geode_robots,
            state.ore_robots + 1,
            state.clay_robots,
            state.obsidian_robots,
            state.geode_robots,
        )
    elseif robot == :clay
        RobotState(
            state.minutes - 1,
            state.ore - blueprint.clay_robot_ore_cost + state.ore_robots,
            state.clay + state.clay_robots,
            state.obsidian + state.obsidian_robots,
            state.geode + state.geode_robots,
            state.ore_robots,
            state.clay_robots + 1,
            state.obsidian_robots,
            state.geode_robots,
        )
    elseif robot == :obsidian
        RobotState(
            state.minutes - 1,
            state.ore - blueprint.obsidian_robot_ore_cost + state.ore_robots,
            state.clay - blueprint.obsidian_robot_clay_cost + state.clay_robots,
            state.obsidian + state.obsidian_robots,
            state.geode + state.geode_robots,
            state.ore_robots,
            state.clay_robots,
            state.obsidian_robots + 1,
            state.geode_robots,
        )
    elseif robot == :geode
        RobotState(
            state.minutes - 1,
            state.ore - blueprint.geode_robot_ore_cost + state.ore_robots,
            state.clay + state.clay_robots,
            state.obsidian - blueprint.geode_robot_obsidian_cost + state.obsidian_robots,
            state.geode + state.geode_robots,
            state.ore_robots,
            state.clay_robots,
            state.obsidian_robots,
            state.geode_robots + 1,
        )
    end
end

function next(state::RobotState)
    return RobotState(
        state.minutes - 1,
        state.ore + state.ore_robots,
        state.clay + state.clay_robots,
        state.obsidian + state.obsidian_robots,
        state.geode + state.geode_robots,
        state.ore_robots,
        state.clay_robots,
        state.obsidian_robots,
        state.geode_robots,
    )
end

function is_finished(state::RobotState)
    state.minutes == 0
end

function max_ore_cost(blueprint::Blueprint)
    max(blueprint.ore_robot_ore_cost, blueprint.clay_robot_ore_cost, blueprint.obsidian_robot_ore_cost, blueprint.geode_robot_ore_cost)
end

function max_clay_cost(blueprint::Blueprint)
    max(blueprint.obsidian_robot_clay_cost, blueprint.geode_robot_obsidian_cost)
end

function max_obsidian_cost(blueprint::Blueprint)
    max(blueprint.geode_robot_obsidian_cost)
end

using DataStructures

function score_blueprint(blueprint::Blueprint)
    score = 0
    cache = DefaultDict{RobotStateTimeless,Int}(-1)

    queue = Stack{RobotState}()
    push!(queue, RobotState())
    while !isempty(queue)

        state = pop!(queue)
        if is_finished(state)
            score = max(score, state.geode)
            continue
        end

        if cache[RobotStateTimeless(state)] >= state.minutes
            continue # skip suboptimal paths
        end

        cache[RobotStateTimeless(state)] = state.minutes

        geode_buildable = is_buildable(blueprint, state, :geode)
        obsidian_buildable = is_buildable(blueprint, state, :obsidian)
        clay_buildable = is_buildable(blueprint, state, :clay)
        ore_buildable = is_buildable(blueprint, state, :ore)

        if geode_buildable
            push!(queue, next(blueprint, state, :geode))
            continue
        end

        push!(queue, next(state))

        if ore_buildable && state.ore_robots < max_ore_cost(blueprint)
            push!(queue, next(blueprint, state, :ore))
        end

        if clay_buildable && state.clay_robots < max_clay_cost(blueprint)
            push!(queue, next(blueprint, state, :clay))
        end
        

        if obsidian_buildable && state.obsidian_robots < max_obsidian_cost(blueprint)
            push!(queue, next(blueprint, state, :obsidian))
        end

        #if !geode_buildable && !obsidian_buildable && !clay_buildable && !ore_buildable
        #end

    end
    score
end

a1 = score_blueprint(blueprints[1])
a2 = score_blueprint(blueprints[2])
a3 = score_blueprint(blueprints[3])

a1 * a2 * a3

sum([score_blueprint(blueprint) * i for (i, blueprint) in enumerate(blueprints)])

function best_score(blueprint::Blueprint)
    global score
    global scores

    score = 0
    scores = [0 for _ in 1:24]

    step(blueprint, RobotState())

    return score
end

best = best_score.(blueprints)

sum([b * i for (i, b) in enumerate(best)])