
# pyrex interface to CoreMIDI
#
# (c) 2006 by Michal Wallace
# available for use under BSD license.
#
# following the example of Donovan Preston's CoreAudio code:
# http://soundfarmer.com/content/code/coreaudio/coreaudio.pyx

cdef extern from "CoreAudio/AudioHardware.h":
    ctypedef int Boolean
    ctypedef int Byte
    ctypedef unsigned int UInt16
    ctypedef unsigned int UInt32
    ctypedef unsigned long UInt64    
    ctypedef signed int SInt32
    ctypedef signed long SInt64    
    ctypedef unsigned int OSStatus
    ctypedef int ByteCount #@TODO: ???


cdef extern from "CoreFoundation/CFBase.h":
    ctypedef UInt32 CFStringEncoding
    ctypedef struct CFStringRef:
        void* __CFString

cdef extern from "CoreFoundation/CFString.h":
    CFStringRef CFStringCreateWithCString(
        void* alloc,
        char* cStr,
        CFStringEncoding encoding)

cdef extern from "Python.h":
    char* PyString_AsString(str)


###########################################################
   
cdef extern from "CoreMIDI/MIDIServices.h":

    ctypedef void* MIDIObjectRef

    ctypedef struct MIDIClientRef:
        void* OpaqueMIDIClient

    ctypedef struct MIDIPortRef:
        void* OpaqueMIDIPort

    ctypedef struct MIDIDeviceRef:
        void* OpaqueMIDIDevice

    ctypedef struct MIDIEntityRef:
        void* MIDIEntityRef
        
    ctypedef struct MIDIEndpointRef:
        void* OpaqueMIDIEndpoint

    # @TODO: how to fix these forward declarations?
    cdef struct fwd_MIDISysexSendRequest:
        void* MIDISysexSendRequest

#    cdef struct MIDIPacketList:
#        void* MIDIPacketList
#    cdef struct MIDINotification:
#        void* MIDINotification

    #--------
    
    ctypedef UInt64 MIDITimeStamp

    ctypedef struct MIDIPacket:
        MIDITimeStamp timeStamp
        UInt16        length
        Byte          data[256]

    ctypedef struct MIDIPacketList:
        UInt32       numPackets
        MIDIPacket   packet[1]


    ctypedef SInt32 MIDINotificationMessageID

    cdef struct MIDINotification:
        MIDINotificationMessageID       messageID
        ByteCount                       messageSize
        # additional data may follow, depending on messageID
        
    cdef enum:
        kMIDIObjectType_Other                   = -1
        kMIDIObjectType_Device                  = 0
        kMIDIObjectType_Entity                  = 1
        kMIDIObjectType_Source                  = 2
        kMIDIObjectType_Destination             = 3

        kMIDIObjectType_ExternalMask            = 0x10,
        kMIDIObjectType_ExternalDevice          = kMIDIObjectType_ExternalMask | kMIDIObjectType_Device
        kMIDIObjectType_ExternalEntity          = kMIDIObjectType_ExternalMask | kMIDIObjectType_Entity
        kMIDIObjectType_ExternalSource          = kMIDIObjectType_ExternalMask | kMIDIObjectType_Source
        kMIDIObjectType_ExternalDestination     = kMIDIObjectType_ExternalMask | kMIDIObjectType_Destination
    

    ctypedef SInt32 MIDIObjectType
    ctypedef SInt32 MIDIUniqueID

    #-- callback signatures ---------

    ctypedef void (*MIDINotifyProc)(MIDINotification* message, void* refCon)
    ctypedef void (*MIDIReadProc)(MIDIPacketList* pktlist, void* readProcRefCon, void* srcConnRefCon)

    ctypedef void (*MIDICompletionProc)(fwd_MIDISysexSendRequest* request)

    #-- structs --------------------

    cdef struct MIDISysexSendRequest:
        MIDIEndpointRef     destination
        Byte *              data
        UInt32              bytesToSend
        Boolean             complete
        Byte                reserved[3]
        MIDICompletionProc  completionProc
        void *              completionRefCon
    


    cdef enum:
        kMIDIMsgSetupChanged            = 1
        kMIDIMsgObjectAdded             = 2
        kMIDIMsgObjectRemoved           = 3
        kMIDIMsgPropertyChanged         = 4
        kMIDIMsgThruConnectionsChanged  = 5
        kMIDIMsgSerialPortOwnerChanged  = 6
        kMIDIMsgIOError                 = 7


    ##############################
        
    OSStatus MIDIClientCreate(
        CFStringRef name,
        MIDINotifyProc notifyProc,
        void* notifyRefCon,
        MIDIClientRef* outClient)  


    OSStatus MIDIInputPortCreate(
        MIDIClientRef   client, 
        CFStringRef     portName, 
        MIDIReadProc    readProc, 
        void *          refCon, 
        MIDIPortRef *   outPort )

    OSStatus MIDIOutputPortCreate(
        MIDIClientRef	client,
        CFStringRef     portName, 
        MIDIPortRef *	outPort )


    MIDIPacket* MIDIPacketNext(
        MIDIPacket*     pkt)


    MIDIEndpointRef MIDIGetSource(
        int i)

    MIDIEndpointRef MIDIGetDestination(
        int i)

    OSStatus MIDIPortConnectSource(
        MIDIPortRef     port,
        MIDIEndpointRef source,
        void*           connRefCon)

    OSStatus MIDISend(
        MIDIPortRef port,
        MIDIEndpointRef dest,
        MIDIPacketList *pktlist )

    #@TODO: ItemCount
    int MIDIGetNumberOfDevices()
    int MIDIGetNumberOfSources()
    int MIDIGetNumberOfDestinations()


# helper function for making CStringRefs
# (probably not the best way to do this, but it seems to work)
cdef CFStringRef pyCFSTR(s):
    cdef char*  cStr
    cStr = PyString_AsString(s)
    return CFStringCreateWithCString(NULL, cStr, 0)

## midi send ##########################################################

def send(a,b,c): 
    cdef MIDIPacketList packetList
    cdef MIDIPacket* packet
    cdef Byte a_
    cdef Byte b_
    cdef Byte c_
    a_ = a
    b_ = b
    c_ = c
    packetList.numPackets = 1

    packet= &packetList.packet[0]
    packet.length = 4
    packet.timeStamp = 0
    packet.data[0] = a_
    packet.data[1] = b_
    packet.data[2] = c_
    
    #print "%s %s %s" % (a, b, c)

    MIDISend(outPort, dest, &packetList)
    

## callback support ###################################################


cdef extern from "Python.h":
    
    ctypedef int PyInterpreterState 
    ctypedef struct PyThreadState:
        PyInterpreterState* interp

    void PyEval_InitThreads()
    PyThreadState* PyEval_SaveThread()
    void PyEval_RestoreThread(PyThreadState* t)
    

    # PyThreadState* PyThreadState_New(PyInterpreterState* i)
    # PyThreadState* PyThreadState_Swap(PyThreadState* t)
    # void PyEval_AcquireThread(PyThreadState* t)
    # void PyEval_ReleaseThread(PyThreadState* t)
 
    ctypedef int PyGILState_STATE
    PyGILState_STATE PyGILState_Ensure()
    void PyGILState_Release(PyGILState_STATE gstate)
    

##[ TEST CODE ]################################################################

cdef void _callback(MIDIPacketList* pktlist, void* refCon, void* connRefCon):

    cdef PyGILState_STATE gil 
    gil = PyGILState_Ensure()
    
    # put all the objety stuff in a separate function so
    # pyrex generated refcount stuff doesn't mess us up
    # http://lists.copyleft.no/pipermail/pyrex/2004-October/000983.html
    call_python_callback(<MIDIPacket*>pktlist.packet)

    PyGILState_Release(gil)


cdef void call_python_callback(MIDIPacket* packet):
    if pyCallback:
        data = []
        for i from 0 <= i < packet.length: # weird
            data.append(packet.data[i])
        pyCallback(data)
    


def pyCallback(data):
    print "midi event:", data
 
    


### init module
    
cdef MIDIClientRef client
cdef MIDIPortRef inPort
cdef MIDIPortRef outPort
cdef MIDIEndpointRef src
cdef MIDIEndpointRef dest

### 
cdef PyThreadState *state
PyEval_InitThreads()
state = PyEval_SaveThread()

MIDIClientCreate(pyCFSTR("CoreMIDI.pyx"), NULL, NULL, &client)
MIDIInputPortCreate(client, pyCFSTR("Input Port"),
                    _callback, NULL, &inPort)
MIDIOutputPortCreate(client, pyCFSTR("Output Port"), &outPort)

PyEval_RestoreThread(state)
####

n = MIDIGetNumberOfSources()
for i from 0 <= i < n:
    src = MIDIGetSource(i)
    MIDIPortConnectSource(inPort, src, NULL)

n = MIDIGetNumberOfDestinations()
if (n < 1): print "CoreMIDI.pyx: no midi destinations found!"
dest = MIDIGetDestination(0)
