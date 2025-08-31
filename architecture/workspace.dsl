workspace "Drone Simulation System" "Digital twin of X500 + Payload with ROS2/Companion integration" {
    
    !include model/system.dsl
    !include model/components_companion1.dsl
    !include model/components_px4.dsl
    #!include environments/environments.dsl

    views {
        !include styles/styles.dsl
        !include views/deployment.dsl
        !include views/containers.dsl
        !include views/components.dsl
        !include views/system_context.dsl
    }
    

    #!include styles.dsl
}