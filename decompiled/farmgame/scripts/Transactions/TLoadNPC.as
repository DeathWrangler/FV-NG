package Transactions
{
   import Classes.FarmIsoViewport;
   import Classes.NPC;
   import Classes.npc.PromoNPC;
   import Engine.Classes.WorldObject;
   import Managers.NPCManager;
   import Managers.WorldManager;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class TLoadNPC extends TBaseWorldLoad
   {
      
      public static const METHOD_LOAD_WORLD:String = "loadWorld";
      
      private var m_npcId:String;
      
      private var m_npc:NPC;
      
      public function TLoadNPC(npcId:String, manager:WorldManager)
      {
         super(manager);
         this.m_npcId = npcId;
      }
      
      override public function perform() : void
      {
         signedCall("NPCService." + METHOD_LOAD_WORLD,this.m_npcId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var actionID:int = 0;
         var idx:int = 0;
         var yetiFarms:Array = null;
         var yetiStillFarms:Array = null;
         var npcClassName:String = result.npcClass;
         var npcId:int = int(this.m_npcId);
         var NPCClass:Class = null;
         try
         {
            NPCClass = getDefinitionByName("Classes.npc." + npcClassName) as Class;
         }
         catch(e:Error)
         {
         }
         if(NPCClass == null)
         {
            NPCClass = PromoNPC;
         }
         this.m_npc = new NPCClass(parseInt(this.m_npcId),npcClassName,result.m_npcConfig);
         NPCManager.getInstance().activeNpc = this.m_npc;
         result.user = {"id":this.m_npcId};
         var outsideOverlay:String = Global.farmGameSettingsManager.getString("backgroundOverlay_" + npcClassName);
         if(outsideOverlay)
         {
            result.world.outsideOverlay = outsideOverlay;
         }
         super.onComplete(result);
         if(Boolean(result.actionsAvailable) && result.actionsAvailable.length > 0)
         {
            for(idx = 0; idx < result.actionsAvailable.length; idx++)
            {
               actionID = int(result.actionsAvailable[idx]);
               this.m_npc.addAction(actionID);
            }
         }
         (GlobalEngine.viewport as FarmIsoViewport).zoomToLevel(2);
         if(this.m_npc.npcConfig.hasOwnProperty("name") && this.m_npc.npcConfig.name == "discover2011")
         {
            yetiFarms = Global.world.getObjectsByName("farm_yetifarm");
            if(yetiFarms.length > 0)
            {
               (yetiFarms[0] as WorldObject).centerOn();
            }
            yetiStillFarms = Global.world.getObjectsByName("farm_yetifarm_still");
            if(yetiStillFarms.length > 0)
            {
               (yetiStillFarms[0] as WorldObject).centerOn();
            }
         }
      }
      
      override protected function onAssetLoadComplete(event:Event) : void
      {
         super.onAssetLoadComplete(event);
         this.m_npc.beginVisitAction();
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_LOAD_WORLD;
         result.npcId = this.m_npcId;
         return result;
      }
   }
}

