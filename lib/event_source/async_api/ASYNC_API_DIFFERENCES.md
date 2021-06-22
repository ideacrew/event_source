# Differences Between Our Objects and the AsyncAPI Spec

This document lists locations where our current object model differs from that presented in the AsyncAPI specification, and where possible, an explanation for why.  It also tracks any areas where we plan to address these differences.

# AMQP Bindings

The spec allows for bindings of exchanges and queues at the channel level only.  Currently in several of our configurations we are loading these at the operation level.