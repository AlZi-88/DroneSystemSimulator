model {
    d = person "Developer" {
        description "You, developing and validating the drone simulation system"
    }

    dsm = softwareSystem "Drone Simulation System" {
        description "A digital twin of the real drone system including PX4, companion computers, and simulated sensors"
        

        gz = container "Gazebo Simulator" {
            description "Simulates the physics, drone model, and environment"
            technology "Gazebo Harmonic"

            lidar = component "Simulated LiDAR" {
                description "Publishes LiDAR pointclouds via ROS2"
                technology "Gazebo plugin (RaySensor) + ROS2 bridge (ros_gz_bridge)"
            }

            camera = component "Simulated Camera Array" {
                description "Publishes simulated camera feeds via ROS2"
                technology "Gazebo plugin (4xRGB Camera) + ROS2 bridge (ros_gz_bridge)"
            }

            payload = component "Simulated Sensor Payload Frame" {
                description "Mass-influencing payload structure with realistic inertia"
                technology "URDF/SDF mass blocks (inertia + origin offset)"
            }
        }

        px4_sitl = container "PX4 Autopilot (SITL)" {
            description "Simulated PX4 running SITL connected to MAVROS or microRTPS"
            technology "PX4 v1.14 SITL (Gazebo / Ignition)"

            middleware_px4 = component "Micro-RTPS Agent" {
                description "Facilitates communication between PX4 and ROS2"
                technology "Micro-RTPS"
            }
        }

        companion_1 = container "Companion Computer 1" {
            description "ROS2 stack running custom agents and data processing"
            technology "Docker (ROS2 Jazzy, Fast DDS, rclcpp, sky_commander stack)"

            middleware_companion_1 = component "Micro-RTPS Client" {
                description "Facilitates communication between Companion 1 and ROS2"
                technology "Micro-RTPS"
            }

            sky_commander_agent = component "Sky Commander Agent" {
                description "Manages drone flight and mission planning"
                technology "ROS2"
            }

            gateway = component "ROS2 Gateway" {
                description "Provides REST APIs for external ROS2 access"
                technology "ROS2"
            }
        }

        companion_2 = container "Companion Computer 2" {
            description "Optional second ROS2 companion for distributed workloads"
            technology "Docker (ROS2 Jazzy, Fast DDS, diagnostics + Web-GUI)"
        }
    }
    d -> companion_1 "Deploys and monitors agents"
    px4_sitl -> companion_1 "Publishes telemetry via uXRCE-DDS"
    gz -> companion_1 "Publishes Images and Pointclouds"
    camera -> companion_2 "Publishes Images"
    companion_2 -> d "Provides webservices"
    payload -> px4_sitl "influences flight model"

    !include environments/simulation.dsl
}