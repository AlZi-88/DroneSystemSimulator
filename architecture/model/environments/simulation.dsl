simulation = deploymentEnvironment "DroneSimulator-Deployment" {
    deploymentNode "Simulation Host (Headless Server)" {
        containerInstance is
    }
    deploymentNode "Companion 1 (Container or VM)" {
        containerInstance companion_1
    }
    deploymentNode "Companion 2 (Container or VM)" {
        containerInstance companion_2
    }
}