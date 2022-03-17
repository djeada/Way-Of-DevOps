> Canary release is a technique to reduce the risk of introducing a new software 
version in production by 
> slowly rolling out the change to a small subset of users before rolling it out to
the entire 
> infrastructure and making it available to everybody.
Source: [martinfowler.com](https://martinfowler.com/bliki/CanaryRelease.html)
Imagine you have two versions: 
* Version A (the stable mainstream version)
* Version B (the version containing a new feature)
There are three ways you can implement the switch between the versions:
* Via routing: You have one system and several servers. Some servers use version A,
some version B. A router decides which server should handle the request
* Via system: You have several systems (for example one system for each customer). 
You can update the system of one customer to version B, while the other customers 
use version A.
* Via code: The source code contains both implementations. According to some 
conditions either code version A or code version B gets executed. You usually use a
feature-flag for this. This feature-flag can be set per user (or per customer).
For example, you updating an internal tool, but you don't want to interrupt the 
work of all developers.
Since it is just for internal tooling, you can implement canary releasing in an 
early adaptors list like this:
```
if user in ['thomas', 'peter', 'hugo', ....]:
 #### new way
else:
 #### old way
```
This way you ensure to don't annoy colleagues with your great new, but not yet 
mature features.
