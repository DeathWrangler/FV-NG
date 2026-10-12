package Classes
{
   import Classes.Constants.CrossPromoConstants;
   import GameMode.GMDefault;
   import Managers.FarmStatsManager;
   
   public class CrossPromoSign extends MapTrigger
   {
      
      public static const Y_OFFSET:Number = -7;
      
      public static const X_OFFSET:Number = 5;
      
      protected var m_crossPromoName:String;
      
      protected var m_onClickCallback:Function;
      
      protected var m_promoGameID:String;
      
      public function CrossPromoSign(promoSignItemName:String, promoName:String, onClickCallback:Function = null)
      {
         var crossPromoDescriptor:CrossPromoDescriptor = null;
         var billboardItemToolTip:String = null;
         this.m_crossPromoName = promoName;
         this.m_onClickCallback = onClickCallback;
         super(promoSignItemName);
         if(Global.crosspromoDescriptorManager.isCrossPromoActive(promoName))
         {
            crossPromoDescriptor = Global.crosspromoDescriptorManager.getCrossPromo(promoName);
            this.m_promoGameID = crossPromoDescriptor.gameID;
            billboardItemToolTip = crossPromoDescriptor.billboardItemToolTip;
            if(billboardItemToolTip != null && billboardItemToolTip.length > 0)
            {
               setOverrideToolTip(billboardItemToolTip);
            }
         }
      }
      
      protected function getPositionData() : Object
      {
         var result:Object = new Object();
         var xPosition:Number = FarmGameWorld(m_outer).getGridWidth() / 2 - m_size.x / 2;
         return {
            "x":xPosition + X_OFFSET,
            "y":Y_OFFSET,
            "z":0
         };
      }
      
      override public function loadObject(data:Object) : void
      {
         if(!data)
         {
            data = {
               "position":{
                  "x":0,
                  "y":0,
                  "z":0
               },
               "state":m_stateToSet
            };
         }
         data.position = this.getPositionData();
         super.loadObject(data);
         FarmStatsManager.count("billboard","xpromo","view",this.promoGameID,this.m_crossPromoName);
      }
      
      protected function get promoGameID() : String
      {
         var gameID:String = this.m_promoGameID;
         if(this.m_promoGameID == null)
         {
            gameID = CrossPromoConstants.GAME_IDS[this.m_crossPromoName];
         }
         return gameID;
      }
      
      override public function onClick() : void
      {
         FarmStatsManager.count("billboard","xpromo","click",this.promoGameID,this.m_crossPromoName);
         if(this.m_onClickCallback != null)
         {
            this.m_onClickCallback(this.m_crossPromoName);
         }
      }
      
      public function hideSign() : void
      {
         detach();
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         this.onClick();
         Global.world.addGameMode(new GMDefault(),true);
      }
   }
}

