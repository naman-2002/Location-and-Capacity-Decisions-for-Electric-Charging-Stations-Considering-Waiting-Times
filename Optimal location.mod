/*********************************************
 * OPL 22.1.1.0 Model
 * Author: 2002n
 * Creation Date: 30-Sep-2024 at 9:12:06 AM
 *********************************************/
int N = 4;
int C = 4;
int L = 16;

range c = 1..C;
range i = 1..N;
range j = 1..N;
range k = 1..L;
range l = 1..L;

tuple Arc{
  int orNode;
  int desNode;
  int btwNode;
  }
tuple Barc{
  int orNode;
  int desNode;
  int btw_1_Node;
  int btw_2_Node;
  }

{Arc} arc =...;

{Barc} barc =...;


float g = ...;   //Cost on each stop on the road
float r = ...;   //Driving range that electric bus can go with full charge
float f[k][c] = ...;  //cost of establishment of electric station with capacity c
                      //at location k

int d[l][l] = ...;  //distance between node i and j
int S[i][j] = ...;    //no. of bus going from i to j node

int M =...;

float V[c] = ...;
float t = ...;
// Define a set of tuples
//set <tuple<int, int, int>> a = ...;
//
//
//// Function to check if (i, j, k) exists in the set a
//int a_value[i in 1..N, j in 1..N, k in 1..L] =
//    if (exists(a, <i, j, k>)) then 1 else 0;
//tuple<int, int, int> myTuple = ...;

// Declare a set of tuples
//set <tuple<int, int, int>> a = ...;

//int a_value[i in 1..N, j in 1..N, k in 1..L] =
//    exists(a, <i, j, k>) ? 1 : 0; 
//    
//int a[i][j][k] = ...;
//int b[i][j][k][l] = ...;
                    
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
    
  forall(a in arc) {
    d[a.orNode][a.desNode] <= r * (1 + (sum(a in arc, m in c)Y[a.btwNode][m]));
}
  forall(a in arc){
    sum(m in c)Y[a.btwNode][m] == 1;
      }
      
//capacity constrainsts

  forall(a in arc){
    W[a.orNode][a.desNode][a.btwNode] <= r*(sum(a in arc, m in c)Y[a.btwNode][m]);
      }
      
  forall(a in arc){
    W[a.orNode][a.desNode][a.btwNode] <= M*E[a.orNode][a.desNode][a.btwNode];
  }  
  
  forall(b in barc){
    Z[b.orNode][b.desNode][b.btw_2_Node] - Z[b.orNode][b.desNode][b.btw_1_Node] + d[b.btw_1_Node][b.btw_2_Node] - Z[b.orNode][b.desNode][b.btw_1_Node] == 0;
}

//  forall(u in i, v in j, h in k, z in l){
//    (Z[u][v][z] - Z[u][v][h] + d[h][z] - W[u][v][h])*b[u][v][h][z] == 0;
//}
  
  forall(a in arc){
    Z[a.orNode][a.desNode][a.btwNode] + W[a.orNode][a.desNode][a.btwNode] <= r;
  }
  
  forall(a in arc){
    Z[a.orNode][a.desNode][a.orNode] <= r;
  }
      

//time constrainst

  forall(a in arc){
    mu[a.btwNode] == (sum(m in c)Y[a.btwNode][m]*V[m]);
  }
  
  forall(a in arc){
    lambda[a.btwNode] == (sum(a in arc)W[a.orNode][a.desNode][a.btwNode]*S[a.orNode][a.desNode]);
  }
  
  forall(a in arc){
    (mu[a.btwNode]-lambda[a.btwNode]) >= (1/t)*(sum(m in c)Y[a.btwNode][m]);
  }    
  
}