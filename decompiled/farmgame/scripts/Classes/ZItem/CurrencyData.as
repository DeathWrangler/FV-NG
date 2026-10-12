package Classes.ZItem
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   
   public class CurrencyData
   {
      
      private static const ATTR_NAME:String = "@name";
      
      private static const NODE_FRIENDLY_NAME:String = "friendlyName";
      
      private static const NODE_ICON:String = "icon";
      
      private static const NODE_INFLOW:String = "inflow";
      
      private static const NODE_OUTFLOW:String = "outflow";
      
      private static const NODE_TUNING_TEST:String = "tuningTest";
      
      private static const NODE_BUFFS:String = "buffs";
      
      private var m_name:String = null;
      
      private var m_friendlyNameKey:String = null;
      
      private var m_icon:String = null;
      
      private var m_stringKeyPrefix:String = null;
      
      private var m_inflowPrereqs:Array = null;
      
      private var m_outflowPrereqs:Array = null;
      
      private var m_currencyConversionItems:Array = null;
      
      private var m_inflowTuningExperimentName:String = null;
      
      private var m_displayVariant:int = 0;
      
      private var m_inflowTuningTestVariants:Array = null;
      
      private var m_buffs:Array = null;
      
      public function CurrencyData(xml:XML)
      {
         var prereqxXmlList:XMLList = null;
         var tuningTest:XMLList = null;
         var buffsList:XMLList = null;
         var children:XMLList = null;
         var childXML:XML = null;
         var index:int = 0;
         var buff:XML = null;
         super();
         if(xml)
         {
            if(xml.hasOwnProperty(ATTR_NAME))
            {
               this.m_name = xml[ATTR_NAME];
            }
            this.m_inflowPrereqs = new Array();
            this.m_outflowPrereqs = new Array();
            this.m_currencyConversionItems = new Array();
            this.m_inflowTuningExperimentName = "";
            this.m_displayVariant = 0;
            this.m_inflowTuningTestVariants = new Array();
            this.m_buffs = new Array();
            children = xml.children();
            for each(childXML in children)
            {
               switch(childXML.name().toString())
               {
                  case NODE_INFLOW:
                     prereqxXmlList = childXML..prereq;
                     if(Boolean(prereqxXmlList) && prereqxXmlList.length() > 0)
                     {
                        this.m_inflowPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(prereqxXmlList);
                     }
                     if(childXML.hasOwnProperty(NODE_TUNING_TEST))
                     {
                        this.initTuningTest(childXML[NODE_TUNING_TEST][0]);
                     }
                     break;
                  case NODE_OUTFLOW:
                     prereqxXmlList = childXML..prereq;
                     if(childXML.prereqs)
                     {
                        this.m_outflowPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(prereqxXmlList);
                     }
                     break;
                  case NODE_FRIENDLY_NAME:
                     this.m_friendlyNameKey = childXML.toString();
                     break;
                  case NODE_ICON:
                     this.m_icon = childXML.toString();
                     break;
                  case NODE_BUFFS:
                     buffsList = childXML.children();
                     for(index = 0; index < buffsList.length(); index++)
                     {
                        buff = buffsList[index];
                        this.m_buffs.push(buff.toString());
                     }
                     break;
                  default:
                     ErrorManager.addError("Encountered unknown currency data node: " + childXML.name());
               }
            }
            return;
         }
         throw new Error("Cannot construct a currency data object from null XML");
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyName() : String
      {
         return ZLocUtils.t_pk(this.m_friendlyNameKey);
      }
      
      public function get icon() : String
      {
         return this.m_icon;
      }
      
      public function get currencyConversionItems() : Array
      {
         return this.m_currencyConversionItems;
      }
      
      public function get stringKeyPrefix() : String
      {
         return this.m_stringKeyPrefix;
      }
      
      public function get inflowPrereqs() : Array
      {
         return this.m_inflowPrereqs;
      }
      
      public function get outflowPrereqs() : Array
      {
         return this.m_outflowPrereqs;
      }
      
      public function get buffs() : Array
      {
         return this.m_buffs;
      }
      
      public function isValidFlow(delta:int) : Boolean
      {
         var result:Boolean = delta == 0;
         if(delta > 0)
         {
            result = this.checkInflowPrereqs();
         }
         else if(delta < 0)
         {
            result = this.checkOutflowPrereqs();
         }
         return result;
      }
      
      public function checkInflowPrereqs() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.m_inflowPrereqs);
      }
      
      public function checkOutflowPrereqs() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.m_outflowPrereqs);
      }
      
      public function getDisplayVariant() : int
      {
         return this.m_displayVariant;
      }
      
      public function getInflowTuningExperimentName() : String
      {
         return this.m_inflowTuningExperimentName;
      }
      
      public function getInflowTuningMultiplierByVariant(experimentVariant:int) : Number
      {
         var result:Number = 1;
         for(var idx:int = 0; idx < this.m_inflowTuningTestVariants.length; idx++)
         {
            if(experimentVariant == this.m_inflowTuningTestVariants[idx]["number"])
            {
               result = Number(this.m_inflowTuningTestVariants[idx]["multiplier"]);
               break;
            }
         }
         return result;
      }
      
      private function initTuningTest(xml:XML) : void
      {
         var variantXml:XML = null;
         if(xml.hasOwnProperty("@experimentName"))
         {
            this.m_inflowTuningExperimentName = xml["@experimentName"];
         }
         if(xml.hasOwnProperty("@displayVariant"))
         {
            this.m_displayVariant = xml["@displayVariant"];
         }
         var variantList:XMLList = xml..variant;
         for(var variantIdx:int = 0; variantIdx < variantList.length(); variantIdx++)
         {
            variantXml = variantList[variantIdx];
            if(variantXml.hasOwnProperty("@number") && variantXml.hasOwnProperty("@multiplier"))
            {
               this.m_inflowTuningTestVariants.push({
                  "number":parseInt(variantXml["@number"]),
                  "multiplier":parseFloat(variantXml["@multiplier"])
               });
            }
         }
      }
   }
}

