package Classes
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Widgets.Windows.WorldProgressWindow;
   import flash.utils.getDefinitionByName;
   
   public class XmlDrivenAction
   {
      
      public static const ACTION_PHOTO_CONTEST:String = "photoContest";
      
      public static const ACTION_DIALOG:String = "showDialog";
      
      public static const ACTION_TRAVEL:String = "worldTravel";
      
      public static const ACTION_FEATURE_CRAFTING:String = "featureCrafting";
      
      private static var m_classCompilingArray:Array = [GenericPopup,WorldProgressWindow,DecoPointsManager];
      
      protected var m_action:XML;
      
      public function XmlDrivenAction(xml:XML)
      {
         super();
         this.m_action = xml;
      }
      
      public function act(params:* = null) : void
      {
         var type:String = null;
         var popupClassName:String = null;
         var popupClass:Class = null;
         if(this.m_action.hasOwnProperty("type"))
         {
            type = this.m_action.type[0].toString();
            switch(type)
            {
               case ACTION_PHOTO_CONTEST:
                  FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,DecoPointsManager.DECOPOINTS_ACTIONMENU,DecoPointsManager.DECOPOINTS_DIALOG_CLICK);
                  DecoPointsManager.instance.openDecoPointsMainUI();
                  break;
               case ACTION_DIALOG:
                  popupClassName = this.m_action.popupClass[0].toString();
                  popupClass = getDefinitionByName(popupClassName) as Class;
                  if(this.m_action.hasOwnProperty("popupConfig"))
                  {
                     UI.displayPopup(new popupClass(this.m_action.popupConfig[0]),true,popupClassName,true);
                  }
                  else if(this.m_action.hasOwnProperty("arg1") && this.m_action.hasOwnProperty("arg2"))
                  {
                     UI.displayPopup(new popupClass(this.m_action.arg1[0].toString(),this.m_action.arg2[0].toString()),true,popupClassName,true);
                  }
                  else if(this.m_action.hasOwnProperty("arg1"))
                  {
                     UI.displayPopup(new popupClass(this.m_action.arg1[0].toString()),true,popupClassName,true);
                  }
                  else
                  {
                     UI.displayPopup(new popupClass(),true,popupClassName,true);
                  }
                  break;
               case ACTION_TRAVEL:
                  FarmStatsManager.count("TravelButton","Travel","Click");
                  Global.worldManager.showTravelConfirmation(this.m_action.arg1[0].toString());
                  break;
               case ACTION_FEATURE_CRAFTING:
                  FeatureCraftingManager.instance.showUI(this.m_action.arg1[0].toString());
                  break;
               default:
                  ErrorManager.addError("Unknown type for XmlDrivenAction button: " + type);
            }
         }
      }
   }
}

