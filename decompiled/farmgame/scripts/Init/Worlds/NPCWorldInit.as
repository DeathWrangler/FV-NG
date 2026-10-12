package Init.Worlds
{
   import Managers.FarmStatsManager;
   
   public class NPCWorldInit extends VisitWorldInit
   {
      
      private var m_npcClass:String = "npcClass empty";
      
      public function NPCWorldInit(destinationUid:String)
      {
         super(destinationUid);
      }
      
      override public function setupHud() : void
      {
         super.setupHud();
         Global.hud.hideAllNameDisplays();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         resultData.id = m_destinationUid;
         if(resultData.hasOwnProperty("npcClass"))
         {
            this.m_npcClass = resultData.npcClass;
            Global.player.setSeenFlag(this.m_npcClass);
         }
         Global.world.m_timeEntered = new Date().time;
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         FarmStatsManager.count(this.m_npcClass,"farm_visit_length",(new Date().time - Global.world.m_timeEntered).toString());
         super.onLeaveWorld(destIsVisiting);
      }
   }
}

