/*********************************************
 * OPL 22.1.1.0 Model
 * Author: 2002n
 * Creation Date: 13-Oct-2024 at 6:56:09 PM
 *********************************************/
int N = 20;
int C = 10;
int L = 47;

range c = 1..C;
range i = 1..N;   //index are also go in this
range j = 1..N;
range k = 1..L;


tuple Arc{
  int orNode;
  int desNode;
  int btwNode;
  int dis_ordes;
  int bus_ordes;
  }
  
tuple Barc{
  int orNode;
  int desNode;
  int btw_1_Node;
  int btw_2_Node;
  int dis_btw_12_node;
  }
  
//tuple Darc{
//  int intNode;
//  int finNode;
//  int distance;
// }


{Arc} arc =...;

{Barc} barc =...;

//{Darc} darc = ...;


float g = ...;   //Cost on each stop on the road
float r = ...;   //Driving range that electric bus can go with full charge
float f[k][c] = ...;  //cost of establishment of electric station with capacity c
                      //at location k

//int d[i][j] = ...;  //distance between node i and j
//int dis[barc]
//int S[i][j] = ...;    //no. of bus going from i to j node

int M =...;

float V[c] = ...;
float t = ...;

                    
//Decision Variable//

dvar int Y[k][c] in 0..1; //1 if charging station with capacity c is established at k node, 0 otherwise
 
dvar int E[i][j][k] in 0..1;  //1 if bus going from i to j stopped at k node, otherwise 0

dvar float+ Z[i][j][k];  //the amount of charge a bus have when it arrive at k node while going from i to j

dvar float+ W[i][j][k];  //the amount of charge a bus will recive at k when going from i to j

dvar float+ mu[k];
dvar float+ lambda[k];

//OBJECTIVE Function//

minimize (sum(a in arc,m in c )f[a.btwNode][m]*Y[a.btwNode][m]) + (sum(a in arc)g*E[a.orNode][a.desNode][a.btwNode]);


//CONSTRAINTS//

subject to{
  
//location Constrainsts
    
  forall(o in arc) {
    o.dis_ordes <= r * (1 + (sum(a in arc, m in c)Y[a.btwNode][m]));
}
  forall(a in arc){
    sum(m in c)Y[a.btwNode][m] <= 1;
      }
      
//capacity constrainsts

  forall(a in arc){
    W[a.orNode][a.desNode][a.btwNode] <= r*(sum(m in c)Y[a.btwNode][m]);
      }
      
  forall(a in arc){
    W[a.orNode][a.desNode][a.btwNode] <= M*E[a.orNode][a.desNode][a.btwNode];
  }  
  
  forall(b in barc){
    Z[b.orNode][b.desNode][b.btw_2_Node] - Z[b.orNode][b.desNode][b.btw_1_Node] 
    + b.dis_btw_12_node - W[b.orNode][b.desNode][b.btw_1_Node] == 0;
}

  
  forall(a in arc){
    Z[a.orNode][a.desNode][a.btwNode] + W[a.orNode][a.desNode][a.btwNode] <= r;
  }
  
  forall(a in arc){
    Z[a.orNode][a.desNode][a.orNode] == r;
  }
  
//  forall(a in arc){
//    W[a.orNode][a.desNode][a.orNode] == r;
//  }
      

//time constrainst

  forall(o in arc){
    mu[o.btwNode] == (sum(m in c)Y[o.btwNode][m]*V[m]);
  }
  
  forall(o in arc){
    lambda[o.btwNode] == (sum(a in arc)W[a.orNode][a.desNode][o.btwNode]*a.bus_ordes);
  }
  
  forall(a in arc){
    (mu[a.btwNode]-lambda[a.btwNode]) >= (1/t)*(sum(m in c)Y[a.btwNode][m]);
  }
  
}