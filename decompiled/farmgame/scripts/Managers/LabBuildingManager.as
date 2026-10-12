package Managers
{
   import Classes.Constants.XMLKeys;
   import flash.utils.Dictionary;
   
   public class LabBuildingManager
   {
      
      private static var m_instance:LabBuildingManager;
      
      private var m_labs:Dictionary;
      
      public function LabBuildingManager()
      {
         super();
         this.m_labs = new Dictionary();
      }
      
      public static function getInstance() : LabBuildingManager
      {
         if(null == m_instance)
         {
            m_instance = new LabBuildingManager();
         }
         return m_instance;
      }
      
      public function setConfigXml(configXml:XML) : void
      {
         var labXml:XML = null;
         for each(labXml in configXml.lab)
         {
            this.m_labs[this.getLabNameFromConfig(labXml)] = labXml;
         }
      }
      
      public function shouldLabShowOnlyCompleted(labCraftSkill:String) : Boolean
      {
         var experimentVariant:int = 0;
         var activeVarsString:String = null;
         var activeVars:Array = null;
         var result:Boolean = false;
         var lab:XML = this.getLabConfigBySkill(labCraftSkill);
         if(lab.hasOwnProperty("mysteryItem"))
         {
            experimentVariant = Global.experimentManager.getExperimentVariant(lab.mysteryItem.@experiment);
            activeVarsString = lab.mysteryItem.@activeVars;
            activeVars = activeVarsString.split(",");
            if(activeVars.indexOf(experimentVariant.toString()) > -1)
            {
               result = true;
            }
         }
         if(result)
         {
            result = lab.hasOwnProperty("showOnlyAnimalsCreated") && lab["showOnlyAnimalsCreated"] == 1;
         }
         return result;
      }
      
      public function getDiscountFactor(labCraftSkill:String) : Number
      {
         var experimentVariant:int = 0;
         var activeVarsString:String = null;
         var activeVars:Array = null;
         var lab:XML = this.getLabConfigBySkill(labCraftSkill);
         var discountPrice:Number = 0;
         if(Boolean(lab) && lab.hasOwnProperty("bushelBundleDiscount"))
         {
            experimentVariant = Global.experimentManager.getExperimentVariant(lab.bushelBundleDiscount.@experiment);
            activeVarsString = lab.bushelBundleDiscount.@activeVars;
            activeVars = activeVarsString.split(",");
            if(activeVars.indexOf(experimentVariant.toString()) > -1)
            {
               discountPrice = Number(lab.bushelBundleDiscount.@discount);
            }
         }
         return discountPrice;
      }
      
      public function getMysteryIcon(labCraftSkill:String) : String
      {
         var lab:XML = this.getLabConfigBySkill(labCraftSkill);
         return lab.mysteryItem.@assetURL;
      }
      
      private function getLabConfigBySkill(labCraftSkill:String) : XML
      {
         var result:XML = null;
         var labName:String = null;
         for(labName in this.m_labs)
         {
            if(this.m_labs[labName].skillType == labCraftSkill)
            {
               result = this.m_labs[labName];
            }
         }
         return result;
      }
      
      public function getLabNameFromConfig(labXml:XML) : String
      {
         var result:String = "";
         if(labXml.hasOwnProperty(XMLKeys.ATTR_NAME))
         {
            result = labXml[XMLKeys.ATTR_NAME];
         }
         return result;
      }
      
      public function getActionButtonName(labName:String) : String
      {
         var result:String = "";
         if(this.m_labs.hasOwnProperty(labName) && Boolean(this.m_labs[labName].hasOwnProperty("actionButtonMethod")))
         {
            result = this.m_labs[labName]["actionButtonMethod"];
         }
         return result;
      }
      
      public function getLabBuilding(labName:String) : XML
      {
         return this.m_labs[labName];
      }
   }
}

