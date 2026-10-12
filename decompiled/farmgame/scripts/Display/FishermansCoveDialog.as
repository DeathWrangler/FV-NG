package Display
{
   import Classes.FeatureBuilding;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import flash.events.Event;
   
   public class FishermansCoveDialog extends FeatureBuildingWithdrawal
   {
      
      private static const DIALOG_ASSET_PATH:String = "assets/dialogs/FV_Cove_Buildable.swf";
      
      private static const DIALOG_TYPE:String = "fishermanscove_withdrawal";
      
      private static const LOCALE_PREFIX:String = "fishermanscove_withdrawal";
      
      private static const BUILDING_NAME:String = "fishermanscove";
      
      private static const WHAT_IS_THIS_IMAGE_PREFIX:String = "assets/dialogs/FV_Support/FV_Expansions_Features/Cove/Buildable/Cove";
      
      public function FishermansCoveDialog(storage:StorageBuilding)
      {
         super(DIALOG_ASSET_PATH,DIALOG_TYPE,LOCALE_PREFIX,storage);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var descriptionKey:String = this.m_storage.getItemName() + this.m_storage.storageLevel.toString() + "_DialogDescription";
         var descriptionString:String = "";
         if(ZLocUtils.hasString("Dialogs",descriptionKey))
         {
            descriptionString = ZLocUtils.t("Dialogs",descriptionKey);
         }
         else
         {
            descriptionString = ZLocUtils.t("Dialogs","fishermanscove_DialogDescription");
         }
         m_window.main_mc.description_tf.text = descriptionString;
         var levelIndex:int = 0;
         while(m_window.main_mc.hasOwnProperty("stage_" + levelIndex + "_mc"))
         {
            m_window.main_mc["stage_" + levelIndex + "_mc"].generic_tf.text = levelIndex + 1;
            levelIndex++;
         }
         this.refreshProgressMeter();
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         TutorialUI.displayBuildingTutorialWindow(FeatureBuilding(this.m_building),WHAT_IS_THIS_IMAGE_PREFIX);
      }
   }
}

