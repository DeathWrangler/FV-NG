package Classes.MOTD
{
   import Classes.FeatureBuilding;
   import Managers.FeatureMessagingManager;
   import Managers.SocialRaffleManager;
   
   public class SocialRaffleMOTDHandler extends ForcePlaceMOTDHandler
   {
      
      public function SocialRaffleMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         var objects:Array = null;
         var worldObject:FeatureBuilding = null;
         if(m_currentMOTD.freeGift)
         {
            objects = Global.world.getObjectsByName(m_currentMOTD.freeGift);
            if(Boolean(objects) && objects.length > 0)
            {
               var _loc3_:int = 0;
               var _loc4_:* = objects;
               for each(worldObject in _loc4_)
               {
                  worldObject.displayStorageDialog();
               }
               FeatureMessagingManager.getInstance().registerFeatureInitialized(m_currentMOTD.freeGift,SocialRaffleManager.getInstance().handleHUDClick);
            }
            else
            {
               super.acceptMOTD();
            }
         }
      }
   }
}

