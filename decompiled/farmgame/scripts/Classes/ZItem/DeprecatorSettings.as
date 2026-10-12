package Classes.ZItem
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ObjectUtil;
   
   public class DeprecatorSettings
   {
      
      private static const ATTR_NAME:String = "@name";
      
      private static const TAG_PREREQS:String = "prereqs";
      
      private static const TAG_REPLACEMENTS:String = "itemReplacements";
      
      private static const TAG_REPLACEMENT:String = "itemReplacement";
      
      private static const TAG_GIFTBOX_ITEMS:String = "giftBoxItems";
      
      private static const TAG_GIFTBOX_ITEM:String = "giftBoxItem";
      
      private static const ATTR_LEVEL:String = "@level";
      
      private static const ATTR_NEW_LEVEL:String = "@newLevel";
      
      private static const ATTR_NEWITEM:String = "@newItem";
      
      private var m_name:String;
      
      private var m_prereqs:XMLList;
      
      private var m_prereqsPassed:Boolean = false;
      
      private var m_prereqsChecked:Boolean = false;
      
      private var m_itemReplacements:XMLList;
      
      private var m_giftBoxItems:XMLList;
      
      public function DeprecatorSettings(xml:XML)
      {
         super();
         if(xml)
         {
            if(xml.hasOwnProperty(ATTR_NAME))
            {
               this.m_name = xml[ATTR_NAME];
            }
            if(ObjectUtil.pathExists(xml,[TAG_PREREQS,PrerequisiteConstants.PREREQ_XML_TAG]))
            {
               this.m_prereqs = xml[TAG_PREREQS][PrerequisiteConstants.PREREQ_XML_TAG];
            }
            if(ObjectUtil.pathExists(xml,[TAG_REPLACEMENTS,TAG_REPLACEMENT]))
            {
               this.m_itemReplacements = xml[TAG_REPLACEMENTS][TAG_REPLACEMENT];
            }
            if(ObjectUtil.pathExists(xml,[TAG_GIFTBOX_ITEMS,TAG_GIFTBOX_ITEM]))
            {
               this.m_giftBoxItems = xml[TAG_GIFTBOX_ITEMS][TAG_GIFTBOX_ITEM];
            }
            return;
         }
         throw new Error("Cannot construct a deprecation settings object from null XML");
      }
      
      public function getPrereqValue(type:String) : String
      {
         var node:XML = null;
         var result:String = null;
         if(this.m_prereqs)
         {
            for each(node in this.m_prereqs)
            {
               if(Boolean(node.hasOwnProperty("@type")) && Boolean(node.@type.toString() == type) && node.hasOwnProperty("@value"))
               {
                  result = node.@value.toString();
                  break;
               }
            }
         }
         return result;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function checkPrereqs(forceRetestOfPrereqs:Boolean = false, context:Object = null) : Boolean
      {
         var result:Boolean = false;
         if(Global.player.isDataLoaded)
         {
            if(this.m_prereqsChecked && forceRetestOfPrereqs == false)
            {
               result = this.m_prereqsPassed;
            }
            else
            {
               result = PrerequisiteUtility.evalPrereqsXML(this.m_prereqs,context);
               this.m_prereqsPassed = result;
               this.m_prereqsChecked = true;
            }
            return result;
         }
         throw new Error("Can\'t check prereqs before player data is loaded");
      }
      
      public function getReplacementEntry(level:String = "") : XML
      {
         var replacer:XML = null;
         var result:XML = null;
         for each(replacer in this.m_itemReplacements)
         {
            if(!replacer.hasOwnProperty(ATTR_LEVEL) || replacer[ATTR_LEVEL] == level)
            {
               result = replacer;
               break;
            }
         }
         return result;
      }
      
      public function getReplacement(level:String = "") : String
      {
         var result:String = "";
         var replacer:XML = this.getReplacementEntry(level);
         if(replacer)
         {
            result = replacer[ATTR_NEWITEM];
         }
         return result;
      }
      
      public function getReplacementLevel(level:String = "") : int
      {
         var result:int = 0;
         var replacer:XML = this.getReplacementEntry(level);
         if(replacer)
         {
            result = int(replacer[ATTR_NEW_LEVEL]);
         }
         return result;
      }
      
      public function getGiftboxItems() : XMLList
      {
         return this.m_giftBoxItems;
      }
   }
}

