package Classes
{
   import Display.UI;
   import Managers.FeatureMessagingManager;
   import Widgets.Windows.UGCFishItemEditorWindow;
   
   public class UGCFishCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function UGCFishCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showUI);
      }
      
      private function showUI() : void
      {
         UI.displayPopup(new UGCFishItemEditorWindow());
      }
   }
}

