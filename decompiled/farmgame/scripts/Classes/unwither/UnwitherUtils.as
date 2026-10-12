package Classes.unwither
{
   import Classes.ZItem.FarmItem;
   import Managers.WorldSeasonsManager;
   
   public class UnwitherUtils
   {
      
      public static const WORLD_UNWITHER_PREFIXES:Object = {
         "farm":"unwitherring",
         "fisherman":"xcoveunwitherring",
         "winterwonderland":"xwwunwitherring",
         "hawaii":"xhiunwitherring",
         "asia":"xasunwitherring",
         "england":"xukunwitherring",
         "hallow":"xhwunwitherring",
         "htown":"xhdunwitherring",
         "glen":"xegunwitherring",
         "atlantis":"xalunwitherring",
         "australia":"xauunwitherring",
         "space":"xspunwitherring",
         "candy":"xcwunwitherring",
         "fforest":"xffunwitherring",
         "hlights":"xlgunwitherring",
         "rainforest":"xrfunwitherring",
         "oz":"xozunwitherring",
         "mediterranean":"xmdunwitherring",
         "oasis":"xoaunwitherring",
         "storybook":"xsbunwitherring",
         "sleepyhollow":"xshunwitherring",
         "toyland":"xtlunwitherring",
         "avalon":"xmaunwitherring,xmbunwitherring",
         "wildwest":"xwaunwitherring",
         "treasuretides":"xsaunwitherring",
         "africa":"xafunwitherring",
         "transylvania":"xtr_unwitherring",
         "japan":"xjp_land_unwitherring,xjp_water_unwitherring,xjp_zen_unwitherring",
         "winter":"xwi_unwitherring",
         "india":"xin_unwitherring",
         "jungle":"xjm_unwitherring",
         "mount":"xmo_unwitherring",
         "limbo":"xbo_unwitherring",
         "xmas":"xch_unwitherring",
         "midwest":"xhh_unwitherring",
         "underwater":"xuw_unwitherring",
         "turtleisland":"xti_unwitherring",
         "dreamworld":"xdw_unwitherring",
         "anglofrench":"xfe_unwitherring",
         "brazil":"xbr_unwitherring",
         "halloweenusa":"xha_unwitherring",
         "whitewinter":"xfw_unwitherring",
         "tuscany":"xty_unwitherring",
         "caribbean":"xcb_unwitherring",
         "dragonvalley":"xdv_unwitherring",
         "russia":"xru_unwitherring",
         "newfrontier":"xnf_unwitherring",
         "israel":"xis_unwitherring",
         "halloweenmad":"xhx_unwitherring",
         "winternord":"xwx_unwitherring",
         "casablanca":"xca_unwitherring",
         "southindia":"xbl_unwitherring",
         "twenties":"xrt_unwitherring",
         "alaska":"xsu_unwitherring",
         "cocoland":"xcl_unwitherring",
         "ireland":"xid_unwitherring",
         "spooky":"xhf_unwitherring",
         "santavillage":"xws_unwitherring",
         "farmfest":"xfs_unwitherring",
         "madagascar":"xmt_unwitherring",
         "borabora":"xbb_unwitherring",
         "amsterdam":"xdm_unwitherring",
         "canada":"xcd_unwitherring",
         "aloha":"xah_unwitherring",
         "pumpkin":"xpu_unwitherring",
         "yuletide":"xyt_unwitherring"
      };
      
      public static const WORLD_UNWITHERBOX_ITEMCODES:Object = {
         "farm":"1k",
         "fisherman":"hh",
         "winterwonderland":"0RG",
         "hawaii":"3L6",
         "asia":"6pX",
         "england":"uR1",
         "hallow":"818",
         "htown":"ar2",
         "glen":"cpt",
         "atlantis":"c29",
         "australia":"fc9",
         "space":"ilz",
         "candy":"uEw",
         "fforest":"unR",
         "hlights":"ta6",
         "rainforest":"xN9",
         "oz":"xrC",
         "mediterranean":"zNT",
         "oasis":"ban2",
         "storybook":"96qi",
         "sleepyhollow":"bjld",
         "toyland":"z2dc",
         "avalon":"ie19,f2cz",
         "wildwest":"l2a6",
         "treasuretides":"fl33",
         "africa":"ry9i",
         "transylvania":"txuf",
         "japan":"qsrf,argz,5xkk",
         "winter":"76bn",
         "india":"v2zr",
         "jungle":"v0nx",
         "mount":"zpxh",
         "limbo":"njua",
         "xmas":"bfms",
         "midwest":"dyi2",
         "underwater":"safg",
         "turtleisland":"1crx",
         "dreamworld":"1fgk",
         "anglofrench":"hpr6",
         "brazil":"cmpo",
         "halloweenusa":"1kmz",
         "whitewinter":"vr17",
         "tuscany":"1pag",
         "caribbean":"j6bw",
         "dragonvalley":"b4ks",
         "russia":"ijl6",
         "newfrontier":"hkx7",
         "israel":"iwe0",
         "halloweenmad":"bcb8",
         "winternord":"zvmd",
         "casablanca":"88r0",
         "southindia":"jkfs",
         "twenties":"8np2",
         "alaska":"tail",
         "cocoland":"jusq",
         "ireland":"3dyw",
         "spooky":"2rbw",
         "santavillage":"q1y6",
         "farmfest":"9hef",
         "madagascar":"74ev",
         "borabora":"p5zt",
         "amsterdam":"l54u",
         "canada":"en9o",
         "aloha":"n62v",
         "pumpkin":"mxos",
         "yuletide":"fjcz"
      };
      
      public static const WORLD_UNWITHERRING_ITEMCODES:Object = {
         "farm":"1a,1b,1c,1d,1e,1f,1g,1h,1i,1j",
         "fisherman":"0lD,0n6,0ob,0oy,0oz,0oA,0oB,0oD,0oC,0oc",
         "winterwonderland":"0RH,0RJ,0RK,0RL,0RM,0RN,0RP,0RQ,0RR,0RS",
         "hawaii":"3L7,3L8,3L9,3Ma,3Mb,3Mc,3Md,3Me,3Mf,3Mg",
         "asia":"6pY,6p3,6p4,6p5,6p7,6p8,6qc,6qf,6qg,6qi",
         "england":"uR2,uR3,uR4,uR5,uR6,uR7,uR8,uR9,uR0,Ur1",
         "hallow":"822,824,827,83l,82c,831,832,834,835,84f",
         "htown":"ar4,asu,asU,as1,as5,as7,ate,atj,atE,atJ",
         "glen":"cpu,cpA,cn2,cnB,cmN,cpp,cpC,cpe,cph,coU",
         "atlantis":"c4T,c4y,c43,c2p,c3S,c5J,c5a,c3b,c5E,dp1",
         "australia":"fdk,fes,fdX,fd4,feb,fd3,fdx,fd0,fd6,fef",
         "space":"imG,ilg,ih0,il6,im2,ij2,imw,imU,ic0,ik0",
         "candy":"q2q,QCz,Zo4,S5O,uhS,L0n,Oq8,vIt,rxu,zfJ",
         "fforest":"Z3f,xkO,ZoX,nos,Psd,nOP,qV5,Smf,ZTS,RGn",
         "hlights":"yFY,ZfT,vTm,rPB,U2T,qCm,xYu,X0e,uVF,P7a",
         "rainforest":"yW6,wU7,YnG,wZ6,XSf,vKk,Zs5,zjr,uks,WaF",
         "oz":"Xci,XoO,WOj,WIh,Zn3,xgW,Uzl,vMk,zHs,WfI",
         "mediterranean":"yVA,ZFG,Z0J,z5u,Zoj,zj5,zc8,ZsO,ZLt,z1C",
         "oasis":"1jyn,o4hs,tw0u,zmvg,eeeh,go1f,11f7,vg61,ln3h,9ovg",
         "storybook":"3go0,qswu,ufq3,7mbj,qa3g,dixa,rh57,7brq,kz1n,ea2j",
         "sleepyhollow":"0mgk,smie,x93q,g0vj,rfxt,ytc2,g1e1,1udv,06ar,8zoa",
         "toyland":"hwnl,p2p1,92mf,x6jl,qbqp,9pc3,0flq,fds5,2e0e,08nv",
         "avalon":"x55j,xoac,mvwv,8un4,ysla,j9km,2rcx,hwwk,vfgz,oraz,5huo,tyy9,hevd,9vxf,yy7k,rqpc,bdwf,gr7x,driw,2kxb",
         "wildwest":"dirs,f0fx,k54v,bxeo,mjjs,nxsj,sin8,qegh,9q0b,d388",
         "treasuretides":"hjiz,lwuc,7rs3,1xrk,un5g,rzec,qu0b,omht,0s37,wjwy",
         "africa":"oozk,brtw,m9zy,1jgs,c2l7,n2do,3whq,0xtg,ofyq,gj81",
         "transylvania":"avxm,w21v,dybl,bzsj,5lim,qbxx,476i,libo,64pu,beop",
         "japan":"1xdh,3vu1,dug0,aghf,q2pg,kid6,golj,ceqg,ed72,mvrk,8d61,rqgr,0wud,4cqc,pl7x,m2ex,fnhn,x9pv,wpdn,jez3,sysp,lxwq,clfo,e12g,7iu2,zwa8,c238,ukba,wvuq,qovv",
         "winter":"eux9,923d,wgli,cxj9,vgsu,2uxt,5ufr,dk01,9lsk,gdlw",
         "india":"ntjq,mkyu,g9fo,zu3g,ww89,shru,wfcd,x03t,hbdi,ayws,",
         "jungle":"q83m,92t1,7o2o,n19g,62eo,314r,djag,cju4,x61h,qjjv,",
         "mount":"j4vw,kqge,5uvl,4yr9,gy8i,8f09,kbmv,bg4l,r41b,112d",
         "limbo":"4oqc,tv59,nbah,hw99,udok,t6io,yq01,3mbs,rwoy,u6rx",
         "xmas":"dquu,jzyk,dz69,kg5c,w75j,8xs2,jy3l,h6io,6myg,cs56,",
         "midwest":"vm36,7hbl,opdu,y7rz,vqh0,1l8m,dyi2,xwiy,w2gv,u15k",
         "underwater":"tc40,7ldo,u8yi,2l2s,fx2y,jpnn,safg,lq3z,rorq,dkh5",
         "turtleisland":"1cvo,1cyn,1cv2,1czk,1czw,1d0v,1dcx,1d1r,1d1v,1d1y,",
         "dreamworld":"isy6,nx80,ni8b,7s2s,axv6,4xwf,khs1,7ce0,xeuk,exnj",
         "anglofrench":"p56l,1nb8,a2u9,5b2e,egoe,6m8i,m0dq,61qg,hc7i,8bso,",
         "brazil":"zz36,ej9d,fjku,poix,sngq,9cik,clzy,9ot7,o83t,1jlf,",
         "halloweenusa":"1kn2,1kmq,6qyg,dp6s,x6kv,jxpd,95xd,duut,otur,zqqd,",
         "whitewinter":"671i,y1q0,llj0,4it7,1tt1,9vgg,3407,ty0q,vy6f,73d5,",
         "tuscany":"hu3j,jyxh,hoq2,ycv1,ranj,xfem,e3rz,guhe,crdd,jd0k,",
         "caribbean":"zckq,67qz,4lne,jhye,wwo7,qnxn,ml33,wd2d,revh,j7id,",
         "dragonvalley":"yoym,wtl6,lwpr,u5hr,pmlq,rab7,n3sl,9geu,zxdh,ego8,",
         "russia":"bb1p,7ki8,x0nj,f8qm,ubof,fja0,lse1,4m6u,z77s,s4sr",
         "newfrontier":"vp87,7r09,sgo0,5mdl,odlg,ecmp,yplt,e2t4,od6q,9aat",
         "israel":"epuk,ji2r,51i4,vu5j,e9x8,2l6z,6ibb,sg8u,ufvd,3cwu",
         "halloweenmad":"9872,trnh,6fae,75q0,ko4x,yrf3,hghk,nun1,ge64,upu7",
         "winternord":"w9qf,owai,n4gi,zcf2,x5qz,nbr9,3ldq,sxml,sysb,qemn",
         "casablanca":"3s5h,xyzl,7g1a,et7z,u5bw,tqwl,kra9,oz8c,io5q,sdjz",
         "southindia":"gm80,l3h8,qkhu,dfxh,qsqh,mnow,b4mh,qk4v,61cm,he7w",
         "twenties":"xp0c,jtt9,h9e2,vlrw,laby,uihj,n20x,jlkk,jah5,v20z",
         "alaska":"o3ns,wziq,aruc,m3is,4w0i,ewkz,rb96,5vbe,mud8,3w74",
         "cocoland":"hmdm,v47q,gjrq,f9au,dxk1,qty4,zegt,p5qj,xnm0,x4el",
         "ireland":"aia0,9lr6,mvdm,xkvr,qblm,x4i0,8akf,sayd,ff00,c771",
         "spooky":"kh55,iivj,sanp,r4pw,si9j,fq2g,gpc3,dgzl,2u9r,6rfi",
         "santavillage":"f02a,5zxm,6p7i,i7zp,vpoi,yesn,gbvx,k767,w36o,l2dg",
         "farmfest":"pn81,recs,nmex,iefv,czcg,llal,s1xu,ayzs,ms8i,ig9y",
         "madagascar":"mszb,8taw,opnq,jtvm,nojx,z2e4,wcbe,qp91,360s,fu81",
         "borabora":"qoxx,g8sf,ursa,3vat,mq2w,yrqg,bg7w,lma4,qh0c,tp8s",
         "amsterdam":"a4de,giu5,5spm,pl74,f4qu,mc6u,w299,lfpx,2pm0,98mg",
         "canada":"et39,tq8o,t5d8,tmnz,h7ie,9j76,ny7t,hcwl,jj5p,3o99",
         "aloha":"q135,sr1i,oftp,wk6x,tgx9,fblu,caam,69ut,d2q5,gbgs",
         "pumpkin":"ec3d,aso4,ieds,pl74,umx5,n716,ei5a,8r6q,x5em,b1e6",
         "yuletide":"tqr1,f581,l0eq,pqqv,hn3h,t9f9,ydfc,zsb7,zvte,k8a9"
      };
      
      internal const EXPERIMENT_FLASH_FESTIVALWINERY_TOASTER:* = "fv_festivalwinery_toaster";
      
      public function UnwitherUtils()
      {
         super();
      }
      
      public static function showUnwitherIconIfNecessary() : void
      {
         Global.hud.iconQueue.removeIconByName("UnwitherOptimization");
      }
      
      public static function isItemUnwitherRingbox(itemCode:String) : Boolean
      {
         var worldString:String = null;
         var boxArray:Array = null;
         var boxCode:String = null;
         var returnVal:Boolean = false;
         for(worldString in WORLD_UNWITHERBOX_ITEMCODES)
         {
            if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldString) > 0)
            {
               boxArray = WORLD_UNWITHERBOX_ITEMCODES[worldString].split(",");
               for each(boxCode in boxArray)
               {
                  if(boxCode == itemCode)
                  {
                     returnVal = true;
                     break;
                  }
               }
            }
            else if(WORLD_UNWITHERBOX_ITEMCODES[worldString] == itemCode)
            {
               returnVal = true;
               break;
            }
         }
         return returnVal;
      }
      
      public static function getWorldUnwitherPrefix(worldCode:String, terrainIndex:int = 0) : String
      {
         var prefixArray:Array = null;
         var returnVal:String = "";
         if(!worldCode)
         {
            worldCode = Global.worldManager.currentWorldType;
         }
         if(terrainIndex >= 0)
         {
            prefixArray = WORLD_UNWITHER_PREFIXES[worldCode].split(",");
            returnVal = prefixArray[terrainIndex];
         }
         else if(WORLD_UNWITHER_PREFIXES.hasOwnProperty(worldCode))
         {
            returnVal = WORLD_UNWITHER_PREFIXES[worldCode];
         }
         return returnVal;
      }
      
      public static function getWorldUnwitherRingboxCode(worldCode:String = null) : String
      {
         var returnVal:String = "";
         if(!worldCode)
         {
            worldCode = Global.worldManager.currentWorldType;
         }
         if(WORLD_UNWITHERBOX_ITEMCODES.hasOwnProperty(worldCode))
         {
            returnVal = WORLD_UNWITHERBOX_ITEMCODES[worldCode];
         }
         return returnVal;
      }
      
      public static function getWorldUnwitherPrefixByItemCode(itemCode:String) : String
      {
         var worldString:String = null;
         var farmItem:FarmItem = null;
         var terrainCodes:Array = null;
         var currentTerrainCode:int = 0;
         var boxArray:Array = null;
         var boxCode:String = null;
         var returnVal:String = "";
         for(worldString in WORLD_UNWITHERBOX_ITEMCODES)
         {
            if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldString) > 0)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               terrainCodes = farmItem.getTerrainSetCodes();
               currentTerrainCode = int(terrainCodes[0]);
               boxArray = WORLD_UNWITHERBOX_ITEMCODES[worldString].split(",");
               for each(boxCode in boxArray)
               {
                  if(boxCode == itemCode)
                  {
                     returnVal = getWorldUnwitherPrefix(worldString,WorldSeasonsManager.getInstance().getTerrainIndex(worldString,currentTerrainCode));
                  }
               }
            }
            else if(WORLD_UNWITHERBOX_ITEMCODES[worldString] == itemCode)
            {
               returnVal = getWorldUnwitherPrefix(worldString);
               break;
            }
         }
         return returnVal;
      }
      
      public static function getUnwitherWorldfromCode(itemCode:String) : String
      {
         var worldString:String = null;
         var boxArray:Array = null;
         var boxCode:String = null;
         var ringArray:Array = null;
         var ringCode:String = null;
         var returnVal:String = "";
         for(worldString in WORLD_UNWITHERBOX_ITEMCODES)
         {
            if(WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldString) > 0)
            {
               boxArray = WORLD_UNWITHERBOX_ITEMCODES[worldString].split(",");
               for each(boxCode in boxArray)
               {
                  if(boxCode == itemCode)
                  {
                     returnVal = worldString;
                     break;
                  }
               }
            }
            else if(WORLD_UNWITHERBOX_ITEMCODES[worldString] == itemCode)
            {
               returnVal = worldString;
               break;
            }
         }
         if(returnVal == "")
         {
            for(worldString in WORLD_UNWITHERRING_ITEMCODES)
            {
               ringArray = WORLD_UNWITHERRING_ITEMCODES[worldString].split(",");
               for each(ringCode in ringArray)
               {
                  if(ringCode == itemCode)
                  {
                     returnVal = worldString;
                     break;
                  }
               }
               if(returnVal != "")
               {
                  break;
               }
            }
         }
         return returnVal;
      }
   }
}

