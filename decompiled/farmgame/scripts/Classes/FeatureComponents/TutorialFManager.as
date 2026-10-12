package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.util.ObjectUtil;
   import DataSources.BaseDataSource;
   import Display.TutorialUI;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Parser.XMLDialogParser;
   import flash.utils.Dictionary;
   
   public class TutorialFManager extends FeatureManager
   {
      
      public static const TUTORIAL_EVENT_PLACEMENT:String = "placement";
      
      public static const TUTORIAL_EVENT_EXPAND_COMPLETE:String = "expandComplete";
      
      public static const TUTORIAL_EVENT_TUTORIAL_WINDOW_CLOSED:String = "tutorialWindowClosed";
      
      private static const XML_ATTRIBUTE_NAME:String = "name";
      
      private static const XML_NODE_NAME_TUTORIAL:String = "tutorial";
      
      private static const XML_ATTRIBUTE_FUNCTION:String = "function";
      
      private static const XML_ATTRIBUTE_ALIAS_FUNCTION_NAME:String = "functionName";
      
      private static const XML_NODE_NAME_TUTORIAL_EVENT:String = "tutorialEvent";
      
      private static const XML_ATTRIBUTE_TUTORIAL:String = "tutorial";
      
      private static const XML_ATTRIBUTE_OPENDIALOG:String = "openDialog";
      
      protected var m_tutorialDictionary:Dictionary;
      
      protected var m_tutorialEventDictionary:Dictionary;
      
      public function TutorialFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var tutorialDataArray:Array = null;
         var tutorialEventDataArray:Array = null;
         var tutorialData:BaseDataSource = null;
         var tutorialName:String = null;
         var tutorialFunctionName:String = null;
         var tutorialObject:Object = null;
         var paramDataArray:Array = null;
         var paramObject:Object = null;
         var paramData:BaseDataSource = null;
         var tutorialEventData:BaseDataSource = null;
         var tutorialEventName:String = null;
         var featuresXML:XMLList = null;
         var tutorialFeatureXML:XMLList = null;
         var xmlNode:XML = null;
         var nameAttr:String = null;
         var nodeName:String = null;
         var functionAttr:String = null;
         var tutorialEvent:Object = null;
         var tutorialEventAttributes:XMLList = null;
         var tutorial:Object = null;
         var tutorialAttributes:XMLList = null;
         var attribute:XML = null;
         var paramsObject:Object = null;
         var attributeName:String = null;
         var eventAttribute:XML = null;
         var eventAttributeName:String = null;
         this.m_tutorialDictionary = new Dictionary();
         this.m_tutorialEventDictionary = new Dictionary();
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.TUTORIAL_MENU_FEATURE_NAME);
            if(featureData)
            {
               tutorialDataArray = [];
               if(featureData.hasProperty(XML_NODE_NAME_TUTORIAL))
               {
                  tutorialDataArray = featureData.getArray(XML_NODE_NAME_TUTORIAL);
               }
               tutorialEventDataArray = [];
               if(featureData.hasProperty(XML_NODE_NAME_TUTORIAL_EVENT))
               {
                  tutorialEventDataArray = featureData.getArray(XML_NODE_NAME_TUTORIAL_EVENT);
               }
               if(tutorialDataArray.length > 0)
               {
                  for each(tutorialData in tutorialDataArray)
                  {
                     tutorialName = tutorialData.getString(XML_ATTRIBUTE_NAME);
                     if(tutorialName.length > 0)
                     {
                        if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
                        {
                           tutorialFunctionName = tutorialData.getString(XML_ATTRIBUTE_ALIAS_FUNCTION_NAME);
                        }
                        else if(FarmGameSettingsManager.isInItemsAMFExperiment())
                        {
                           tutorialFunctionName = tutorialData.getString(XML_ATTRIBUTE_ALIAS_FUNCTION_NAME);
                        }
                        else
                        {
                           tutorialFunctionName = tutorialData.getString(XML_ATTRIBUTE_FUNCTION);
                        }
                        if(tutorialFunctionName.length > 0)
                        {
                           tutorialObject = tutorialData.getAttributesHash();
                           paramDataArray = tutorialData.getArray("param");
                           if(paramDataArray.length > 0)
                           {
                              paramObject = {};
                              for each(paramData in paramDataArray)
                              {
                                 paramObject[paramData.getString("name")] = paramData.getString("value");
                              }
                              tutorialObject.params = paramObject;
                           }
                           tutorialObject[XML_ATTRIBUTE_OPENDIALOG] = tutorialData.getBoolean(XML_ATTRIBUTE_OPENDIALOG);
                           this.m_tutorialDictionary[tutorialName] = tutorialObject;
                        }
                     }
                  }
               }
               if(tutorialEventDataArray.length > 0)
               {
                  for each(tutorialEventData in tutorialEventDataArray)
                  {
                     tutorialEventName = tutorialEventData.getString(XML_ATTRIBUTE_NAME);
                     if(tutorialEventName.length > 0)
                     {
                        this.m_tutorialEventDictionary[tutorialEventName] = tutorialEventData.getAttributesHash();
                     }
                  }
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            tutorialFeatureXML = featuresXML.(@name == FeatureManager.TUTORIAL_MENU_FEATURE_NAME);
            if(tutorialFeatureXML != null)
            {
               for each(xmlNode in tutorialFeatureXML.*)
               {
                  nameAttr = xmlNode.attribute(XML_ATTRIBUTE_NAME);
                  if(nameAttr.length <= 0)
                  {
                     continue;
                  }
                  nodeName = xmlNode.name().toString();
                  switch(nodeName)
                  {
                     case XML_NODE_NAME_TUTORIAL:
                        functionAttr = xmlNode.attribute(XML_ATTRIBUTE_FUNCTION);
                        if(functionAttr.length > 0)
                        {
                           tutorial = new Object();
                           tutorialAttributes = xmlNode.attributes();
                           for each(attribute in tutorialAttributes)
                           {
                              attributeName = attribute.name();
                              tutorial[attributeName] = attribute.toString();
                           }
                           paramsObject = XMLDialogParser.getNameValueParamsFromNode(xmlNode);
                           if(ObjectUtil.objectHasProperties(paramsObject))
                           {
                              tutorial["params"] = paramsObject;
                           }
                           tutorial[XML_ATTRIBUTE_OPENDIALOG] = tutorial[XML_ATTRIBUTE_OPENDIALOG] == "true";
                           this.m_tutorialDictionary[nameAttr] = tutorial;
                        }
                        break;
                     case XML_NODE_NAME_TUTORIAL_EVENT:
                        tutorialEvent = {};
                        tutorialEventAttributes = xmlNode.attributes();
                        for each(eventAttribute in tutorialEventAttributes)
                        {
                           eventAttributeName = eventAttribute.name();
                           tutorialEvent[eventAttributeName] = eventAttribute.toString();
                        }
                        this.m_tutorialEventDictionary[nameAttr] = tutorialEvent;
                  }
               }
            }
         }
      }
      
      public function onTutorialEvent(eventName:String) : Boolean
      {
         var shouldShow:Boolean = false;
         var tutorialName:String = null;
         var tutorial:Object = null;
         var seenFlagName:String = null;
         var tutorialShown:Boolean = false;
         var tutorialEvent:Object = this.m_tutorialEventDictionary[eventName];
         if(tutorialEvent != null)
         {
            shouldShow = true;
            tutorialName = tutorialEvent.tutorial;
            if(tutorialName != null && tutorialName.length > 0)
            {
               tutorial = this.m_tutorialDictionary[tutorialName];
               if(tutorial != null)
               {
                  seenFlagName = tutorial.seenFlag;
                  if(seenFlagName != null && seenFlagName != "")
                  {
                     if(!Global.player.getSeenFlag(seenFlagName))
                     {
                        Global.player.setSeenFlag(seenFlagName);
                     }
                     else
                     {
                        shouldShow = false;
                     }
                  }
                  if(shouldShow)
                  {
                     if(tutorial[XML_ATTRIBUTE_OPENDIALOG])
                     {
                        m_owner.displayStorageDialog();
                     }
                     tutorialShown = this.showTutorial(tutorial);
                  }
               }
            }
         }
         return tutorialShown;
      }
      
      private function showTutorial(tutorial:Object) : Boolean
      {
         var prefixUrl:String = null;
         var paramsObject:Object = null;
         var tutorialShown:Boolean = true;
         var func:String = tutorial[XML_ATTRIBUTE_FUNCTION];
         var tutorialClass:Class = TutorialUI;
         if(tutorialClass.hasOwnProperty(func))
         {
            switch(func)
            {
               case "updateGrowableContestTutorialState":
                  TutorialUI.updateGrowableContestTutorialState(m_owner);
                  break;
               case "forcePlaceGiftboxDialog":
                  TutorialUI.forcePlaceGiftboxDialog(tutorial.item,tutorial.message,tutorial.button,tutorial.seenFlag,tutorial.fromMarket == "true");
                  break;
               case "surfaceStorageBuilding":
                  tutorialShown = TutorialUI.surfaceStorageBuilding(m_owner,tutorial.surfacingKeyword);
                  break;
               case "displayBuildingTutorialWindow":
                  FarmStatsManager.count("dialog",m_owner.getItemName(),"what_is_this","open");
                  prefixUrl = m_owner.getItem().prefixUrl;
                  TutorialUI.displayBuildingTutorialWindow(m_owner,prefixUrl,false,this.howDoesThisWorkCloseCallback,tutorial.button,tutorial.hideCloseButton == "true");
                  break;
               case "displayBuildingUI":
                  break;
               case "showIrrigationFTUEWindow":
                  TutorialUI.showIrrigationFTUEWindow(tutorial.windowSrc,tutorial.itemPlaceOnAccept);
                  break;
               default:
                  tutorialClass[func]();
            }
         }
         else if(func == "displayPopup")
         {
            if("params" in tutorial)
            {
               paramsObject = tutorial["params"];
            }
            owner.displayDialog("storage",paramsObject);
         }
         return tutorialShown;
      }
      
      private function howDoesThisWorkCloseCallback() : void
      {
         FarmStatsManager.count("dialog",m_owner.getItemName(),"what_is_this","close");
         this.onTutorialEvent(TUTORIAL_EVENT_TUTORIAL_WINDOW_CLOSED);
      }
   }
}

