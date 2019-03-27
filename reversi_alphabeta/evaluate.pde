//石数の差を数える
int total() {
  int dn=0;
  
  for (int k=1;k<=8;k++){
    for (int l=1;l<=8;l++){dn += bw*board[k][l];} //両者の石数の差を数える
  }
	
  return dn; //評価を返す
}

//着手した石の位置を評価
float posMoves(int i, int j){
  float dn=0;
  
  //隅の評価
  if ((i==1&&j==1)||(i==1&&j==8)||(i==8&&j==1)||(i==8&&j==8)) {dn=10;}
  
  //隅が空の時のX
  else if (board[1][1]==0 && (i==2&&j==2)) {dn=-15;} //左上のX
  else if (board[1][8]==0 && (i==2&&j==7)) {dn=-15;} //左下のX
  else if (board[8][1]==0 && (i==7&&j==2)) {dn=-15;} //右上のX
  else if (board[8][8]==0 && (i==7&&j==7)) {dn=-15;} //右下のX
  
  //隅が空の時のC
  else if (board[1][1]==0 && ((i==1&&j==2)||(i==2&&j==1))) {dn=-10;} //左上のC
  else if (board[1][8]==0 && ((i==1&&j==7)||(i==2&&j==8))) {dn=-10;} //左下のC
  else if (board[8][1]==0 && ((i==7&&j==1)||(i==8&&j==2))) {dn=-10;} //右上のC
  else if (board[8][8]==0 && ((i==8&&j==7)||(i==7&&j==8))) {dn=-10;} //右下のC*/
  
  //隅が空の時のC
  /*else if (board[1][1]==0 && board[1][8]==0) { //左辺のC
    if(board[1][3]==0 && board[1][4]==0 && board[1][5]==0 && board[1][6]==0 &&
        ((i==1&&j==2)||(i==1&&j==7)) ){dn=-10;} //辺に打たれてない時
    else{dn=-3;}
  }
  else if (board[1][1]==0 && board[8][1]==0) { //上辺のC
    if(board[3][1]==0 && board[4][1]==0 && board[5][1]==0 && board[6][1]==0 &&
        ((i==2&&j==1)||(i==7&&j==1)) ){dn=-10;} //辺に打たれてない時
    else{dn=-3;}
  }
  else if (board[8][1]==0 && board[8][8]==0) { //右辺のC
    if(board[8][3]==0 && board[8][4]==0 && board[8][5]==0 && board[8][6]==0 &&
        ((i==8&&j==2)||(i==8&&j==7)) ){dn=-10;} //辺に打たれてない時
    else{dn=-3;}
  }
  else if (board[1][8]==0 && board[8][8]==0) { //下辺のC
    if(board[3][8]==0 && board[4][8]==0 && board[5][8]==0 && board[6][8]==0 &&
        ((i==2&&j==8)||(i==7&&j==8)) ){dn=-10;} //辺に打たれてない時
    else{dn=-3;}
  } //*/
  
  return 1.0*dn; //補正分の枚数を返す
}

//開放度理論による評価（小さいほど良い）
float kaihodo(int i, int j) {
  float dn=0;
  int ri, rj; //調べるマスを移動させるのに使う変数

  for (int di=-1; di<=1; di++) { //横方向
    for (int dj=-1; dj<=1; dj++) { //縦方向
      ri = i+di;  rj=j+dj; //調べるマスの初期値を与える
      
      //調べるマスが「盤の中」かつ「相手の石」ならループ
      while (board[ri][rj]!=2 && board[ri][rj]==-bw){
        ri+=di; rj+=dj; //次のマスに移動
        
        //同色の石に出会った時、元の石まで戻りつつ周囲の空きマスを勘定
        if (board[ri][rj]==bw) {
          ri-=di; rj-=dj; //1マス戻る
          
          while (!(i==ri&&j==rj)) { //元のマスに戻るまで続ける
            //周囲の空きマスを数える
            for (int di2=-1; di2<=1; di2++) { //横方向
              for (int dj2=-1; dj2<=1; dj2++) { //縦方向
                if (board[ri+di2][rj+dj2]==0){dn--;} //開放度は大きいほど不利
              }
            }
            ri-=di; rj-=dj; //また1マス戻る
          }
        }
      }
    }
  }
  
  return 3.0*dn;
}

//両者の合法手数を評価
float numMoves() {
  float dn=0;
  
  for(int o=1;o<=2;o++){ //両者を評価(自分→相手)
    int dm=0;
    
    for (int k=1;k<=8;k++) {
      for (int l=1;l<=8;l++) {
        if(!(k==2&&l==2 || k==2&&l==7 || k==7&&l==2 || k==7&&l==7)){ //X以外
        //if ((3<=k&&k<=6)||(3<=l&&l<=6)){ //隅周辺以外
          if(validMove(k,l)){dm++;} //着手可能数(多い程良い)
        }
      }
    }
    if (dm==0) {dm=-30;} //合法手が0個
    else if (dm==1) {dm=-10;} //合法手が1個
    
    //自分の評価(o=1)なら加点、相手の評価(o=2)なら減点
    if(o==1){dn+=dm;}  else{dn-=dm;}
    
    bw = -bw; //石の色を反転
  }
  
  return 1.0*dn;
}

//辺の確定石の評価
float absolute() {
  float dn=0;
  
  //上下の辺を評価
  for(int q=1;q<=8;q+=7){
    if(abs(board[1][q]+board[8][q])==1){ //片隅が打たれている時
      //各隅から調べ、同じ石が続く間、加点する
      int p=1;  while(board[p][q]==board[1][q]){dn += bw*board[1][q];  p++;} //左から右
      p=8;  while(board[p][q]==board[8][q]){dn += bw*board[8][q];  p--;} //右から左
    }
    else if(board[1][q]!=0 && board[8][q]!=0){ //両隅が打たれている時
      for(int r=1;r<=8;r++){dn += bw*board[r][q];} //両者の石を加点
    }
  }
  
  //左右の辺を評価
  for(int p=1;p<=8;p+=7){
    if(abs(board[p][1]+board[p][8])==1){ //片隅が打たれている時
      //各隅から調べ、同じ石が続く間、加点する
      int q=1;  while(board[p][q]==board[p][1]){dn += bw*board[p][1];  q++;} //上から下
      q=8;  while(board[p][q]==board[p][8]){dn += bw*board[p][8];  q--;} //下から上
    }
    else if(board[p][1]!=0 && board[p][8]!=0){ //両隅が打たれている時
      for(int r=1;r<=8;r++){dn += bw*board[p][r];} //両者の石を加点
    }
  }
  
  return 3.0*dn;
}

//辺の形状(ブロック、ウイング、山)の評価
float edge() {
  float dn=0;
  
  //上下の辺を評価
  for(int p=1;p<=8;p+=7){
    if(board[1][p]==0 && board[8][p]==0){ //両隅が空の時
      //石のブロックがある時
      if(abs(board[3][p]+board[4][p]+board[5][p]+board[6][p]) == 4){
        //ブロックの評価(両隣のCが2つとも空の時)
        if(board[2][p]==0 && board[7][p]==0){dn += 1.0*bw*board[3][p];}
        
        //ウイングの評価(片方のCにブロックと同じ石がある時)
        //if(board[2][p]==board[3][p] && board[7][p]==0){dn += -1.0*bw*board[3][p];}
        //else if(board[2][p]==0 && board[7][p]==board[6][p]){dn += -1.0*bw*board[3][p];}
        
        //山の評価(両隣のCが2つともブロックと同じ石の時)
        else if(board[2][p]==board[3][p] && board[7][p]==board[6][p]){dn += 3.0*bw*board[3][p];}
      }
    }
  }
  
  //左右の辺を評価
  for(int p=1;p<=8;p+=7){
    if(board[p][1]==0 && board[p][8]==0){ //両隅が空の時
      //石のブロックがある時
      if(abs(board[p][3]+board[p][4]+board[p][5]+board[p][6]) == 4){
        //ブロックの評価(両隣のCが2つとも空の時)
        if(board[p][2]==0 && board[p][7]==0){dn += 1.0*bw*board[p][3];}
        
        //ウイングの評価(片方のCにブロックと同じ石がある時)
        //if(board[p][2]==board[p][3] && board[p][7]==0){dn += -1.0*bw*board[p][3];}
        //else if(board[p][2]==0 && board[p][7]==board[p][6]){dn += -1.0*bw*board[p][3];}
        
        //山の評価(両隣のCが2つともブロックと同じ石の時)
        else if(board[p][2]==board[p][3] && board[p][7]==board[p][6]){dn += 3.0*bw*board[p][3];}
      }
    }
  }
  
  return 1.0*dn;
}



//次に相手が隅を取れるか調べる
float corner(int i, int j) {
  float dn = 0;
  
  movePiece(i,j); //石を仮に打って、返せる石を返す
  
  //次に相手が隅に打てる場合、評価を落とす
  bw = -bw; //石の色を反転
  if (validMove(1,1)){dn-=10;} //左上隅
  if (validMove(1,8)){dn-=10;} //左下隅
  if (validMove(8,1)){dn-=10;} //右上隅
  if (validMove(8,8)){dn-=10;} //右下隅
  bw = -bw; //石の色を元に戻す
  
  recorder(false); //元の盤面に戻す
  
  return 0.0*dn;
}

//全マスの重み付け評価
float table(){
  float dn=0;
  //int SS=100, CC=-50, AA=10, BB=0, XX=-70, midA=-5, midB=-10, boxX=-10, boxB=-5, cent=0;
  //int SS=20, CC=-10, AA=2, BB=0, XX=-15, midA=-1, midB=-2, boxX=-2, boxB=-1, cent=0;
  int SS=0, CC=0, AA=0, BB=0, XX=0, midA=-1, midB=-2, boxX=-2, boxB=-1, cent=0;
  
  int weight[][] = {
    {   SS,   CC,   AA,   BB,   BB,   AA,   CC,   SS},
    {   CC,   XX, midA, midB, midB, midA,   XX,   CC},
    {   AA, midA, boxX, boxB, boxB, boxX, midA,   AA},
    {   BB, midB, boxB, cent, cent, boxB, midB,   BB},
    {   BB, midB, boxB, cent, cent, boxB, midB,   BB},
    {   AA, midA, boxX, boxB, boxB, boxX, midA,   AA},
    {   CC,   XX, midA, midB, midB, midA,   XX,   CC},
    {   SS,   CC,   AA,   BB,   BB,   AA,   CC,   SS}
  };  //*/
  
  for (int k=1;k<=8;k++) {
    for (int l=1;l<=8;l++) {
      //(手番の色)*(盤上の石の色)*(重み)
      if(board[k][l]!=0){dn += bw*board[k][l]*weight[k-1][l-1];}
    }
  }
  
  return 0.0*dn; //0.3*dn; //補正分の枚数を返す
}

//全滅判定
float extinction(){
  float dn=0; //
  int db=0, dw=0;
  
  for (int k=1;k<=8;k++){  //黒白それぞれの石数を数える
    for (int l=1;l<=8;l++){
      if(board[k][l]== 1){db++;}
      if(board[k][l]==-1){dw++;}
    }
  }
  
  if(db==0||dw==0){dn = 2000*bw *(db-dw)/abs(db-dw);}  //全滅
  else if(db==0||dw==0){dn = 10*bw *(db-dw)/abs(db-dw);}  //1枚
  
  return 0.0*dn; //評価を返す
}
