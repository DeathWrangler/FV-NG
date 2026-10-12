package Classes
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Widgets.Windows.Expansion.MeadowsComingSoonWindow;
   import Widgets.Windows.WanderingPirateWindow;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class DialogMapTrigger extends MapTrigger
   {
      
      private var m_assetPath:String = null;
      
      private var m_className:String = null;
      
      private var m_parameters:XML = null;
      
      protected var m_windowTypes:Array = [MeadowsComingSoonWindow,WanderingPirateWindow];
      
      public function DialogMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("dialogUrl"))
         {
            this.m_assetPath = xmlData.dialogUrl;
         }
         if(xmlData.hasOwnProperty("windowClassName"))
         {
            this.m_className = xmlData.windowClassName;
         }
         xmlData.featureName = name;
         this.m_parameters = xmlData;
      }
      
      override public function onClick() : void
      {
         var windowClass:Class = getDefinitionByName(this.m_className) as Class;
         var window:* = new windowClass(this.m_assetPath,this.m_parameters);
         UI.displayPopup(window);
         var dispObjName:String = getQualifiedClassName(window);
         StatsManager.count("NPC","Clicks",dispObjName);
         super.onClick();
      }
   }
}

