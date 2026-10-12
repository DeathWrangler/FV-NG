package Classes.Tutorial
{
   import Classes.FeatureBuilding;
   import Classes.Managers.HUDTutorialManager;
   
   public class OpenFeatureBuildingWindowState implements IHUDTutorialState
   {
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      public function OpenFeatureBuildingWindowState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var itemCode:String = this.m_ftueConfig.itemCode;
         var objectArray:Array = Global.world.getObjectsByCode(itemCode);
         if(objectArray != null && objectArray.length > 0)
         {
            (objectArray[0] as FeatureBuilding).displayStorageDialog();
         }
         this.m_completed = true;
         HUDTutorialManager.instance.step();
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
      }
   }
}

