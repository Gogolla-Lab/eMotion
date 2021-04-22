import PySpin


def configure_acquisition_mode(cam):
    """
    This function sets the camera acquisition mode to continuous.

    :param cam: Camera to acquire images from.
    :type cam: CameraPtr
    :return: True if successful, False otherwise.
    :rtype: bool
    """

    print('*** CONFIGURING ACQUISITION MODE ***\n')
    try:
        result = True

        # Set acquisition mode to continuous
        #
        #  *** NOTES ***
        #  Setting the value of an enumeration node is slightly more complicated
        #  than other node types. Two nodes must be retrieved: first, the
        #  enumeration node is retrieved from the nodemap; and second, the entry
        #  node is retrieved from the enumeration node. The integer value of the
        #  entry node is then set as the new value of the enumeration node.
        #
        #  Notice that both the enumeration and the entry nodes are checked for
        #  availability and readability/writability. Enumeration nodes are
        #  generally readable and writable whereas their entry nodes are only
        #  ever readable.

        # Retrieve GenICam nodemap (nodemap)
        nodemap = cam.GetNodeMap()

        # Retrieve enumeration node from nodemap
        # In order to access the node entries, they have to be casted to a pointer type (CEnumerationPtr here)
        node_acquisition_mode = PySpin.CEnumerationPtr(nodemap.GetNode('AcquisitionMode'))
        if not PySpin.IsAvailable(node_acquisition_mode) or not PySpin.IsWritable(node_acquisition_mode):
            print('Unable to set acquisition mode to continuous (enum retrieval). Aborting...')
            return False

        # Retrieve entry node from enumeration node
        node_acquisition_mode_continuous = node_acquisition_mode.GetEntryByName('Continuous')
        if not PySpin.IsAvailable(node_acquisition_mode_continuous) or not PySpin.IsReadable(
                node_acquisition_mode_continuous):
            print('Unable to set acquisition mode to continuous (entry retrieval). Aborting...')
            return False

        # Retrieve integer value from entry node
        acquisition_mode_continuous = node_acquisition_mode_continuous.GetValue()

        # Set integer value from entry node as new value of enumeration node
        node_acquisition_mode.SetIntValue(acquisition_mode_continuous)

        print('Acquisition mode set to continuous...')

    except PySpin.SpinnakerException as ex:
        print('Error: %s' % ex)
        return False

    return result


def configure_exposure(cam, exposure_time: int):
    """
    This function configures a custom exposure time. Automatic exposure is turned off in order to allow for the
    customization, and then the custom setting is applied.

     :param cam: Camera to configure exposure for.
     :type cam: CameraPtr
     :param exposure_time: exposure time in microseconds
     :type exposure_time: int
     :return: True if successful, False otherwise.
     :rtype: bool
    """

    print('*** CONFIGURING EXPOSURE ***\n')

    try:
        result = True

        # Turn off automatic exposure mode
        #
        # *** NOTES *** Automatic exposure prevents the manual configuration of exposure times and needs to be turned
        # off. Enumerations representing entry nodes have been added to QuickSpin. This allows for the much easier
        # setting of enumeration nodes to new values.
        #
        # The naming convention of QuickSpin enums is the name of the enumeration node followed by an underscore and
        # the symbolic of the entry node. Selecting "Off" on the "ExposureAuto" node is thus named "ExposureAuto_Off".

        if cam.ExposureAuto.GetAccessMode() != PySpin.RW:
            print('Unable to disable automatic exposure. Aborting...')
            return False

        cam.ExposureAuto.SetValue(PySpin.ExposureAuto_Off)
        print('Automatic exposure disabled...')

        # Set exposure time manually; exposure time recorded in microseconds
        #
        # *** NOTES *** Notice that the node is checked for availability and writability prior to the setting of the
        # node. In QuickSpin, availability and writability are ensured by checking the access mode.
        #
        # Further, it is ensured that the desired exposure time does not exceed the maximum. Exposure time is counted
        # in microseconds - this can be found out either by retrieving the unit with the GetUnit() method or by
        # checking SpinView.

        if cam.ExposureTime.GetAccessMode() != PySpin.RW:
            print('Unable to set exposure time. Aborting...')
            return False

        # Ensure desired exposure time does not exceed the maximum
        exposure_time_to_set = exposure_time
        exposure_time_to_set = min(cam.ExposureTime.GetMax(), exposure_time_to_set)
        cam.ExposureTime.SetValue(exposure_time_to_set)
        print('Shutter time set to %s us...\n' % exposure_time_to_set)

    except PySpin.SpinnakerException as ex:
        print('Error: %s' % ex)
        result = False

    return result


def configure_gain(cam, gain: float):
    """
    This function configures the camera gain.

    :param cam: Camera to acquire images from.
    :type cam: CameraPtr
    :param gain: gain in dB
    :type gain: float or string (only 'off')
    :return: True if successful, False otherwise.
    :rtype: bool
    """

    print('*** CONFIGURING ACQUISITION MODE ***\n')
    try:
        result = True

        # Retrieve GenICam nodemap (nodemap)
        nodemap = cam.GetNodeMap()

        # Retrieve node
        node_gainauto_mode = PySpin.CEnumerationPtr(nodemap.GetNode("GainAuto"))
        if not PySpin.IsAvailable(node_gainauto_mode) or not PySpin.IsWritable(node_gainauto_mode):
            print('Unable to configure gain (enum retrieval). Aborting...')
            return False

        # EnumEntry node (always associated with an Enumeration node)
        node_gainauto_mode_off = node_gainauto_mode.GetEntryByName("Off")
        if not PySpin.IsAvailable(node_gainauto_mode_off) or not PySpin.IsWritable(node_gainauto_mode_off):
            print('Unable to configure gain (entry retrieval). Aborting...')
            return False

        # Turn off Auto Gain
        node_gainauto_mode.SetIntValue(node_gainauto_mode_off.GetValue())
        print("Auto gain set to 'off'")

        # Retrieve gain node (float)
        node_gain = PySpin.CFloatPtr(nodemap.GetNode("Gain"))
        if not PySpin.IsAvailable(node_gain) or not PySpin.IsWritable(node_gain):
            print('Unable to configure gain (float retrieval). Aborting...')
            return False

        if gain > 40:
            print("Max. gain is 40dB. Change the code if you'd like to increase it!")
            gain = 40.0
        elif gain <= 0 or gain == 'off':
            gain = 0.0

        # Set gain
        node_gain.SetValue(float(gain))
        print('Gain set to {} dB'.format(gain))

    except PySpin.SpinnakerException as ex:
        print('Error: %s' % ex)
        return False

    return result


def configure_trigger(cam, trigger_type='hardware'):
    """
    This function configures the camera to use a trigger. First, trigger mode is ensured to be off in order to select 
    the trigger source. Trigger mode is then enabled, which has the camera capture only a single image upon the 
    execution of the chosen trigger. 

     :param trigger_type: 'hardware' or 'software'
     :type trigger_type: str
     :param cam: Camera to configure trigger for.
     :type cam: CameraPtr
     :return: True if successful, False otherwise.
     :rtype: bool
    """

    print('*** CONFIGURING TRIGGER ***\n')
    print(
        'Note that if the application / user software triggers faster than frame time, the trigger may be dropped / '
        'skipped by the camera.\n')
    print(
        'If several frames are needed per trigger, a more reliable alternative for such case, is to use the '
        'multi-frame mode.\n\n')

    if trigger_type == 'hardware':
        print('Hardware trigger chosen...')
    elif trigger_type == 'software':
        print('Software trigger chosen...')

    try:
        result = True

        # Ensure trigger mode off. The trigger must be disabled in order to configure whether the source is software
        # or hardware.
        if cam.TriggerMode.GetAccessMode() != PySpin.RW:
            print('Unable to disable trigger mode (node retrieval). Aborting...')
            return False
        cam.TriggerMode.SetValue(PySpin.TriggerMode_Off)
        print('Trigger mode disabled...')

        # Set TriggerSelector to FrameStart. This is the default for most cameras.
        if cam.TriggerSelector.GetAccessMode() != PySpin.RW:
            print('Unable to get trigger selector (node retrieval). Aborting...')
            return False
        cam.TriggerSource.SetValue(PySpin.TriggerSelector_FrameStart)
        print('Trigger selector set to frame start...')

        # Select trigger source. The trigger source must be set to hardware or software while trigger mode is off.
        if cam.TriggerSource.GetAccessMode() != PySpin.RW:
            print('Unable to get trigger source (node retrieval). Aborting...')
            return False

        if trigger_type == 'hardware':
            cam.TriggerSource.SetValue(PySpin.TriggerSource_Line0)
            print('Trigger source set to hardware...')
        elif trigger_type == 'software':
            cam.TriggerSource.SetValue(PySpin.TriggerSource_Software)
            print('Trigger source set to software...')

        # Turn trigger mode on. Once the appropriate trigger source has been set, turn trigger mode on in order to
        # retrieve images using the trigger.
        cam.TriggerMode.SetValue(PySpin.TriggerMode_On)
        print('Trigger mode turned back on...')

    except PySpin.SpinnakerException as ex:
        print('Error: %s' % ex)
        return False

    return result
