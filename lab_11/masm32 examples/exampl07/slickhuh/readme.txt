The SLICKHUH demo shows how to write code the wrong way so you can feel
profound about writing garbage that no-one including yourself can
understand.

It uses the EXTERNDEF form of prototype for API functions but makes no use
of the parameter data after it, Windows equates occur in their bare number
form to ensure they are unintelligible and the API function addresses are
called from a meaningless name equated to their address.

To make the code even less readable in a disassembly the parameters for
some of the  API call are forwarded on the stack and do not occur in the
simple order prior to the function call.

To see how its done the right way, have a look at the masm1k example.