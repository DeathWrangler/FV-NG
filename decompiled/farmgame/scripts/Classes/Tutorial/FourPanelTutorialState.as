package Classes.Tutorial
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import flash.events.Event;
   
   public class FourPanelTutorialState implements IHUDTutorialState
   {
      
      private static const IMAGE:String = "image";
      
      private var m_ftueConfig:Object;
      
      private var m_isCompleted:Boolean;
      
      private var m_featureName:String;
      
      public function FourPanelTutorialState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         if(this.m_ftueConfig.dialogKey)
         {
            this.m_featureName = this.m_ftueConfig.dialogKey;
         }
         var items:Array = new Array();
         var imageNumber:int = 1;
         var propertyString:String = IMAGE + imageNumber.toString();
         while(this.m_ftueConfig.hasOwnProperty(propertyString))
         {
            items.push({
               "overview":this.m_featureName + "_Slot" + imageNumber + "Overview",
               "title":this.m_featureName + "_Slot" + imageNumber + "Title",
               "body":this.m_featureName + "_Slot" + imageNumber + "Body",
               "imageUrl":this.m_ftueConfig[propertyString],
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs"
            });
            imageNumber++;
            propertyString = IMAGE + imageNumber.toString();
         }
         TutorialUI.displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs",this.m_featureName + "_Title"),false,false,this.updateProgress);
      }
      
      private function updateProgress(event:Event = null) : void
      {
         this.m_isCompleted = true;
         HUDTutorialManager.instance.step();
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_isCompleted;
      }
      
      public function cleanUp() : void
      {
      }
   }
}

