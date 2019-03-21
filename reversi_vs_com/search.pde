int opening=2, mid_d=5, end_d=14; //5,14. 7,16.
int score_max=9000;
int x=0,y=0; //最大評価のマスの位置

//石を打てる所を探して打つ
void com(){
  float n=0,max=-2*score_max;//評価値の最大値
  int place=0; //打てるか判定
  //String[][] board_value = new String[10][10]; //各マスの評価値
  node_count=0;
  
  if(start==false && turn==-1){ //初期画面が終わり、手番がAI(-1)の時
		
    recorder(true); //石の配置を記録
    for (int i=1;i<=8;i++){
      for (int j=1;j<=8;j++){
        if (validMove(i,j)){ //打てる所があれば実行
          float m = posMoves(i,j) +kaihodo(i,j);
          //float m = kaihodo(i,j);
          
          movePiece(i,j); //仮に打つ
          bw = -bw; //石の色を反転
          move++;
          place=1;
          
          //評価関数
          if(move <= opening) { //opening手目まではバラつかせる
            n = random(0.5);
            
            //board_value[i][j] = nfs(round(n),4);
            print(i +"-" +j +"," +nfs(round(n),4) +";   ");
          }
          else if(move <= 60-end_d) { //60-end_d手目まではmid_d手読み
            n = -negascout(mid_d-1,-score_max,score_max,0)
                 +m -numMoves() +random(0.5);
            
            //board_value[i][j] = nfs(round(n),4);
            print(i +"-" +j +"," +nfs(round(n),4) +";   ");
          }
          else { //残り60-end_d手から完全読み
            n = -negaalpha(end_d-1,-score_max,score_max,0) +0.5/(1.0+exp(-m));  //シグモイド関数
            
            //board_value[i][j] = nfs(round(n),3) +"!";
            print(i +"-" +j +"," +nfs(round(n),3) +"!;   ");
          }
          
          move--;
          bw = -bw; //石の色を戻す
          recorder(false); //元の盤面に戻す
          
          //これまでの最大値より大きい時
          if (max<n){max=n;  x=i; y=j;}
        }
        //else{board_value[i][j] = "-----";};
      }
    }
    
    if (place==1) { //打てれば実行
			println("");
			
      //各マスの評価値を表示
      /*for (int i=1;i<=8;i++){
        for (int j=1;j<=8;j++){
          print(board_value[j][i] +",");
        }
        println("");
      }//*/
      
      movePiece(x,y); //返せる石を反転
      move++;
      
      println(">> mv"+ nf(move,2) +",COM"+ x +"-"+ y +";  values = "+ nfs(round(max),4) +";  nodes = " +node_count +";  ");
      println("");
      bw = -bw; //石の色を反転
      turn = -turn; //手番交替
      showBoard(); //盤面、両者の石、次の手番、打てる所を描画
      x=0;  y=0;
    }
  }
}

int node_count=0; //探索した局面数を数える

//ネガスカウト法
float negascout(float depth,float a,float b,int pass2){
  float n=-score_max,value, w1;
  int r=0,w2, place=0; //打てるか判定
  float[] v=new float[50];
  int[] p=new int[50],q=new int[50]; //並び替え用
  
  //深さ制限に達したら評価値を返す
  if (depth<=0 || move>=60) {node_count++;  return mid_d*(absolute() +edge());}
  
  //打てる所を簡易評価
  recorder(true); //石の配置を記録
  for (int k=1;k<=8;k++){ //相手の手を探し、簡易的に評価
    for (int l=1;l<=8;l++){
      if (validMove(k,l)){
        r++;  p[r]=k;  q[r]=l;
        v[r] = posMoves(k,l) +kaihodo(k,l);
      }
    }
  }
  for (int s=1; s<=r-1; s++){ //評価の大きい順にMove ordering(バブルソート)
    for (int t=r; s<=t-1; t--){
      if(v[t-1]<v[t]){
        w1=v[t];  v[t]=v[t-1];  v[t-1]=w1;
        w2=p[t];  p[t]=p[t-1];  p[t-1]=w2;
        w2=q[t];  q[t]=q[t-1];  q[t-1]=w2;
      }
    }
  }
  //print("r=" +r +"_");
  //for(int s=1; s<=r; s++){print(v[s] +", ");}
  //println("");
  
  //最適手を再帰で探索
  for (int s=1;s<=r;s++){ //再帰で探索
    float m = posMoves(p[s],q[s]) +kaihodo(p[s],q[s]);
    //float m = kaihodo(p[s],q[s]);
    
    movePiece(p[s],q[s]);
    bw=-bw;
    move++;
    place=1; //打てると判定
    
    //探索長さ
    float dd = 1.0;
    if(r<=5){dd = float(r-1)/float(r);}  //合法手数に応じて延長
    if((p[s]<=2||7<=p[7])&&(q[s]<=2||7<=q[7])){dd = 0.5;}  //隅周辺に打つ時は延長
    
    //相手の手を再帰で評価(自分はα<value<β、相手は-β<-value<-α)
    value = -negascout(depth-dd,-b,-a,0) +m -numMoves();
    
    //相手の手をNull Window Search(自分はα<value<α+1)
    //if(a<value && value<b && depth!=mid_d && depth>2){
      //value = -negascout(depth-1,-b,-value,0) +m -numMoves();
    //}
    
    move--;
    recorder(false); //1手前の局面に戻す
    
    if (b<=value) {return value;} //上限値以上なら探索打ち切り
    if (n<value) { //最大値を超えたら置換、下限値も更新
      n = value;
      a = max(a,n);
    }
    
    //b=a+1;  //新しい null windowを設定
  }
  
  //1回目のパスなら現局面のまま、自分の手を再帰で評価
  if(place==0 && pass2==0){
    bw=-bw;
    value = -negascout(depth-0.2,-b,-a,1) -30;  //続けて打てれば高評価
    bw=-bw;
    return value;
  }
  
  //2回目のパスなら終局時の石数を評価
  else if(place==0 && pass2==1){
    int t = total();
    if(t>0){n = score_max *(depth/mid_d +1)/2;} //自分の方が多ければ勝ち
    else if(t<0){n = -score_max *(depth/mid_d +1)/2;} //相手の方が多ければ負け
    else{n = 0;}
  }
  
  return n;
}

//ネガアルファ法
int negaalpha(int depth,int a,int b,int pass2){
  int n=-score_max,value;
  float w1;
  int r=0,w2, place=0; //打てるか判定
  float[] v=new float[50];
  int[] p=new int[50],q=new int[50]; //並び替え用
  
  //深さ制限に達したら評価値を返す
  if (depth<=0 || move>=60) {node_count++;  return total();}
  
  //相手に打てる所があれば、1手読みで仮探索
  recorder(true); //石の配置を記録
  for (int k=1;k<=8;k++){ //相手の手を探し、簡易的に評価
    for (int l=1;l<=8;l++){
      if (validMove(k,l)){
        r++;  p[r]=k;  q[r]=l;
        v[r] = posMoves(k,l) +kaihodo(k,l);
      }
    }
  }
  
  //評価の大きい順にMove ordering(バブルソート)
  for (int s=1; s<=r-1; s++){
    for (int t=r; s<=t-1; t--){
      if(v[t-1]<v[t]){
        w1=v[t];  v[t]=v[t-1];  v[t-1]=w1;
        w2=p[t];  p[t]=p[t-1];  p[t-1]=w2;
        w2=q[t];  q[t]=q[t-1];  q[t-1]=w2;
      }
    }
  }
	
  //最適手を再帰で探索
  for (int s=1;s<=r;s++){ //再帰で探索
    movePiece(p[s],q[s]);
    bw=-bw;
    move++;
    place=1; //打てると判定
    
    //相手の手を再帰で評価(自分はα<value<β、相手は-β<-value<-α)
    value = -negaalpha(depth-1,-b,-a,0);
    
    move--;
    recorder(false); //1手前の局面に戻す
    
    if (b<=value) {return value;} //上限値以上なら探索打ち切り
    if (n<value) { //最大値を超えたら置換、下限値も更新
      n = value;
      a = max(a,n);
    }
  }
  
  //1回目のパスなら現局面のまま、自分の手を再帰で評価
  if(place==0 && pass2==0){
    bw=-bw;
    value = -negaalpha(depth,-b,-a,1);
    bw=-bw;
    return value;
  }
  
  //2回目のパスなら終局時の石数を評価
  else if(place==0 && pass2==1){n=total();}
  
  return n;
}
