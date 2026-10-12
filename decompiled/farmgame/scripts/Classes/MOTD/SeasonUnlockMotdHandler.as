package Classes.MOTD
{
   public class SeasonUnlockMotdHandler extends CustomWindowMOTDHandler
   {
      
      private var m_worldType:String = null;
      
      public function SeasonUnlockMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(m_currentMOTD.hasOwnProperty("worldType"))
         {
            this.m_worldType = m_currentMOTD["worldType"];
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         if(this.m_worldType)
         {
            if(Global.worldManager.currentWorldType != this.m_worldType)
            {
               Global.worldManager.swapFarm(this.m_worldType,true,true);
            }
            else
            {
               Global.worldManager.loadNextSeason(this.m_worldType);
            }
         }
      }
   }
}

