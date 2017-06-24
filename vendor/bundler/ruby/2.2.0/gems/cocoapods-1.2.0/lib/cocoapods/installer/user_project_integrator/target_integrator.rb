require 'active_support/core_ext/string/inflections'

module Pod
  class Installer
    class UserProjectIntegrator
      # This class is responsible for integrating the library generated by a
      # {TargetDefinition} with its destination project.
      #
      class TargetIntegrator
        autoload :XCConfigIntegrator, 'cocoapods/installer/user_project_integrator/target_integrator/xcconfig_integrator'

        # @return [String] the PACKAGE emoji to use as prefix for every build phase aded to the user project
        #
        BUILD_PHASE_PREFIX = '[CP] '.freeze

        # @return [String] the name of the check manifest phase
        #
        CHECK_MANIFEST_PHASE_NAME = 'Check Pods Manifest.lock'.freeze

        # @return [Array<Symbol>] the symbol types, which require that the pod
        # frameworks are embedded in the output directory / product bundle.
        #
        # @note This does not include :app_extension or :watch_extension because
        # these types must have their frameworks embedded in their host targets.
        # For messages extensions, this only applies if it's embedded in a messages
        # application.
        #
        EMBED_FRAMEWORK_TARGET_TYPES = [:application, :unit_test_bundle, :ui_test_bundle, :watch2_extension, :messages_application].freeze

        # @return [String] the name of the embed frameworks phase
        #
        EMBED_FRAMEWORK_PHASE_NAME = 'Embed Pods Frameworks'.freeze

        # @return [String] the name of the copy resources phase
        #
        COPY_PODS_RESOURCES_PHASE_NAME = 'Copy Pods Resources'.freeze

        # @return [AggregateTarget] the target that should be integrated.
        #
        attr_reader :target

        # Init a new TargetIntegrator
        #
        # @param  [AggregateTarget] target @see #target
        #
        def initialize(target)
          @target = target
        end

        # Integrates the user project targets. Only the targets that do **not**
        # already have the Pods library in their frameworks build phase are
        # processed.
        #
        # @return [void]
        #
        def integrate!
          UI.section(integration_message) do
            XCConfigIntegrator.integrate(target, native_targets)

            add_pods_library
            add_embed_frameworks_script_phase
            remove_embed_frameworks_script_phase_from_embedded_targets
            add_copy_resources_script_phase
            add_check_manifest_lock_script_phase
          end
        end

        # @return [String] a string representation suitable for debugging.
        #
        def inspect
          "#<#{self.class} for target `#{target.label}'>"
        end

        private

        # @!group Integration steps
        #---------------------------------------------------------------------#

        # Adds spec product reference to the frameworks build phase of the
        # {TargetDefinition} integration libraries. Adds a file reference to
        # the frameworks group of the project and adds it to the frameworks
        # build phase of the targets.
        #
        # @return [void]
        #
        def add_pods_library
          frameworks = user_project.frameworks_group
          native_targets.each do |native_target|
            build_phase = native_target.frameworks_build_phase

            # Find and delete possible reference for the other product type
            old_product_name = target.requires_frameworks? ? target.static_library_name : target.framework_name
            old_product_ref = frameworks.files.find { |f| f.path == old_product_name }
            if old_product_ref.present?
              UI.message("Removing old Pod product reference #{old_product_name} from project.")
              build_phase.remove_file_reference(old_product_ref)
              frameworks.remove_reference(old_product_ref)
            end

            # Find or create and add a reference for the current product type
            target_basename = target.product_basename
            new_product_ref = frameworks.files.find { |f| f.path == target.product_name } ||
              frameworks.new_product_ref_for_target(target_basename, target.product_type)
            build_phase.build_file(new_product_ref) ||
              build_phase.add_file_reference(new_product_ref, true)
          end
        end

        # Find or create a 'Embed Pods Frameworks' Copy Files Build Phase
        #
        # @return [void]
        #
        def add_embed_frameworks_script_phase
          native_targets_to_embed_in.each do |native_target|
            add_embed_frameworks_script_phase_to_target(native_target)
          end
        end

        # Removes the embed frameworks build phase from embedded targets
        #
        # @note Older versions of CocoaPods would add this build phase to embedded
        #       targets. They should be removed on upgrade because embedded targets
        #       will have their frameworks embedded in their host targets.
        #
        def remove_embed_frameworks_script_phase_from_embedded_targets
          return unless target.requires_host_target?
          native_targets.each do |native_target|
            if AggregateTarget::EMBED_FRAMEWORKS_IN_HOST_TARGET_TYPES.include? native_target.symbol_type
              remove_embed_frameworks_script_phase(native_target)
            end
          end
        end

        def add_embed_frameworks_script_phase_to_target(native_target)
          phase = create_or_update_build_phase(native_target, EMBED_FRAMEWORK_PHASE_NAME)
          script_path = target.embed_frameworks_script_relative_path
          phase.shell_script = %("#{script_path}"\n)
        end

        # Delete a 'Embed Pods Frameworks' Copy Files Build Phase if present
        #
        # @param [PBXNativeTarget] native_target
        #
        def remove_embed_frameworks_script_phase(native_target)
          embed_build_phase = native_target.shell_script_build_phases.find { |bp| bp.name && bp.name.end_with?(EMBED_FRAMEWORK_PHASE_NAME) }
          return unless embed_build_phase.present?
          native_target.build_phases.delete(embed_build_phase)
        end

        # Adds a shell script build phase responsible to copy the resources
        # generated by the TargetDefinition to the bundle of the product of the
        # targets.
        #
        # @return [void]
        #
        def add_copy_resources_script_phase
          phase_name = COPY_PODS_RESOURCES_PHASE_NAME
          native_targets.each do |native_target|
            phase = create_or_update_build_phase(native_target, phase_name)
            script_path = target.copy_resources_script_relative_path
            phase.shell_script = %("#{script_path}"\n)
          end
        end

        # Adds a shell script build phase responsible for checking if the Pods
        # locked in the Pods/Manifest.lock file are in sync with the Pods defined
        # in the Podfile.lock.
        #
        # @note   The build phase is appended to the front because to fail
        #         fast.
        #
        # @return [void]
        #
        def add_check_manifest_lock_script_phase
          phase_name = CHECK_MANIFEST_PHASE_NAME
          native_targets.each do |native_target|
            phase = create_or_update_build_phase(native_target, phase_name)
            native_target.build_phases.unshift(phase).uniq! unless native_target.build_phases.first == phase
            phase.shell_script = <<-SH.strip_heredoc
              diff "${PODS_ROOT}/../Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
              if [ $? != 0 ] ; then
                  # print error to STDERR
                  echo "error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation." >&2
                  exit 1
              fi
            SH
          end
        end

        private

        # @!group Private Helpers
        #---------------------------------------------------------------------#

        # @return [Array<PBXNativeTarget>] The list of all the targets that
        #         match the given target.
        #
        def native_targets
          @native_targets ||= target.user_targets
        end

        # @return [Array<PBXNativeTarget>] The list of all the targets that
        #         require that the pod frameworks are embedded in the output
        #         directory / product bundle.
        #
        def native_targets_to_embed_in
          return [] if target.requires_host_target?
          native_targets.select do |target|
            EMBED_FRAMEWORK_TARGET_TYPES.include?(target.symbol_type)
          end
        end

        # Read the project from the disk to ensure that it is up to date as
        # other TargetIntegrators might have modified it.
        #
        # @return [Project]
        #
        def user_project
          target.user_project
        end

        # @return [Specification::Consumer] the consumer for the specifications.
        #
        def spec_consumers
          @spec_consumers ||= target.pod_targets.map(&:file_accessors).flatten.map(&:spec_consumer)
        end

        # @return [String] the message that should be displayed for the target
        #         integration.
        #
        def integration_message
          "Integrating target `#{target.name}` " \
            "(#{UI.path target.user_project_path} project)"
        end

        def create_or_update_build_phase(target, phase_name, phase_class = Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
          prefixed_phase_name = BUILD_PHASE_PREFIX + phase_name
          build_phases = target.build_phases.grep(phase_class)
          build_phases.find { |phase| phase.name && phase.name.end_with?(phase_name) }.tap { |p| p.name = prefixed_phase_name if p } ||
            target.project.new(phase_class).tap do |phase|
              UI.message("Adding Build Phase '#{prefixed_phase_name}' to project.") do
                phase.name = prefixed_phase_name
                phase.show_env_vars_in_log = '0'
                target.build_phases << phase
              end
            end
        end
      end
    end
  end
end
