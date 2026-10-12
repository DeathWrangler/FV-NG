package Classes.Minigames
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class MinigameData
   {
      
      private static const TAG_ZLOCPREFIX:String = "zlocPrefix";
      
      private static const TAG_FEATURE_OPTIONS_ENTRY:String = "featureOptionsEntry";
      
      private static const TAG_PREREQS:String = "prereqs";
      
      private static const FEATURE_CLASS_PATH:String = "Classes.Minigames.";
      
      private static const FEATURE_CLASS_NAME:String = "FeatureData";
      
      private static const ATTR_NAME:String = "@name";
      
      private static const DECLARE_KNOWN_TYPES:Array = [DialogFeatureData,RedeemablesFeatureData,CardMatchingGameFeatureData,TokenPlayFeatureData];
      
      private var m_name:String = null;
      
      private var m_zlocPrefix:String = null;
      
      private var m_featureOptionsEntryName:String = null;
      
      private var m_prereqs:Array = null;
      
      private var m_featureHash:Dictionary = null;
      
      public function MinigameData(xml:XML)
      {
         var featureList:XMLList = null;
         var featureData:BaseFeatureData = null;
         var featureClass:Class = null;
         var featureName:String = null;
         var featureXML:XML = null;
         super();
         if(xml)
         {
            this.m_name = this.parseString(xml,ATTR_NAME);
            this.m_zlocPrefix = this.parseString(xml,TAG_ZLOCPREFIX);
            this.m_featureOptionsEntryName = this.parseString(xml,TAG_FEATURE_OPTIONS_ENTRY,this.defaultFeatureOptionsEntryName());
            if(xml.hasOwnProperty(TAG_PREREQS))
            {
               this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml[TAG_PREREQS].children());
            }
            featureList = xml.features.feature;
            featureData = null;
            featureClass = null;
            featureName = null;
            this.m_featureHash = new Dictionary();
            for each(featureXML in featureList)
            {
               featureName = null;
               try
               {
                  if(featureXML.hasOwnProperty(ATTR_NAME))
                  {
                     featureName = FarmGameUtil.toUpperCaseFirst(featureXML[ATTR_NAME]);
                     featureClass = getDefinitionByName(FEATURE_CLASS_PATH + featureName + FEATURE_CLASS_NAME) as Class;
                     featureData = new featureClass(featureXML,this);
                     this.m_featureHash[featureData.name] = featureData;
                  }
                  else
                  {
                     ErrorManager.addError("MinigameData: Error for minigame name=" + this.m_name + ": minigame feature tag is missing name attribute.");
                  }
               }
               catch(e:Error)
               {
                  if(e.errorID == 1065)
                  {
                     ErrorManager.addError("MinigameData: Error minigame name=" + m_name + ": failed new " + featureName + FEATURE_CLASS_NAME + "().  Class needs to be added to DECLARE_KNOWN_TYPES array.");
                  }
                  else
                  {
                     ErrorManager.addError("MinigameData: Error minigame name=" + m_name + ": failed new " + featureName + FEATURE_CLASS_NAME + "().  " + e.toString());
                  }
               }
            }
         }
      }
      
      private function get className() : String
      {
         return getQualifiedClassName(this);
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get zlocPrefix() : String
      {
         return this.m_zlocPrefix;
      }
      
      public function get featureOptionsEntryName() : String
      {
         return this.m_featureOptionsEntryName;
      }
      
      protected function parseString(xml:XML, token:String, defaultValue:String = null) : String
      {
         var result:String = null;
         if(xml.hasOwnProperty(token))
         {
            result = xml[token].toString();
         }
         else
         {
            if(defaultValue == null)
            {
               throw new Error("Error: " + this.className + " missing required " + token + " tag for xml=" + xml);
            }
            result = defaultValue;
         }
         return result;
      }
      
      public function getFeatureData(featureKey:String) : BaseFeatureData
      {
         return this.m_featureHash[featureKey];
      }
      
      public function prereqsMet() : Boolean
      {
         var failedOne:Boolean = false;
         var prereq:Object = null;
         var result:Boolean = false;
         if(this.m_prereqs)
         {
            failedOne = false;
            for each(prereq in this.m_prereqs)
            {
               if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
               {
                  failedOne = true;
                  break;
               }
            }
            result = !failedOne;
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      private function defaultFeatureOptionsEntryName() : String
      {
         return this.m_name + "_game";
      }
   }
}

