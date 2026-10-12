package Classes.UGC
{
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   
   public class UGCUtil
   {
      
      private static var s_colorMap:Object;
      
      private static const UUID_V4_REGEX:RegExp = /[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}/i;
      
      private static const FISH_ITEMNAME:String = "ugc_fish";
      
      public function UGCUtil()
      {
         super();
      }
      
      private static function makeKey(ugcItem:String, key:String) : String
      {
         var updatedItemName:String = ugcItem;
         if(ugcItem.indexOf(FISH_ITEMNAME) >= 0)
         {
            updatedItemName = FISH_ITEMNAME;
         }
         return UGCConstants.ZLOC_PREFIX + updatedItemName + "_" + key;
      }
      
      public static function t(ugcItem:IUGCItem, key:String, subs:Object = null) : String
      {
         return ZLocUtils.t(UGCConstants.ZLOC_PACKAGE,makeKey(ugcItem.ugcItemName,key),subs);
      }
      
      public static function t2(featureName:String, key:String, subs:Object = null) : String
      {
         return ZLocUtils.t(UGCConstants.ZLOC_PACKAGE,makeKey(featureName,key),subs);
      }
      
      public static function hasString(ugcItem:IUGCItem, key:String) : Boolean
      {
         return ZLocUtils.hasString(UGCConstants.ZLOC_PACKAGE,makeKey(ugcItem.ugcItemName,key));
      }
      
      public static function validateUUID(uuid:String) : Boolean
      {
         var result:Boolean = false;
         if(uuid != null)
         {
            result = UUID_V4_REGEX.test(uuid);
            UUID_V4_REGEX.lastIndex = 0;
         }
         return result;
      }
      
      public static function getColorName(color:uint) : String
      {
         var data:Object = null;
         var name:String = "";
         if(color < UGCConstants.COLOR_UNSET)
         {
            if(s_colorMap == null)
            {
               s_colorMap = new Object();
               for each(data in UGCConstants.COLOR_DATA)
               {
                  if(data["color"] != null && data["name"] != null)
                  {
                     s_colorMap[data.color.toString()] = data.name;
                  }
                  else
                  {
                     ErrorManager.addError("Invalid color data found in UGCConstants.COLOR_DATA, color and name are required");
                  }
               }
               for each(data in UGCConstants.COLOR_DATA_FISH)
               {
                  if(data["color"] != null && data["name"] != null)
                  {
                     s_colorMap[data.color.toString()] = data.name;
                  }
                  else
                  {
                     ErrorManager.addError("Invalid color data found in UGCConstants.COLOR_DATA, color and name are required");
                  }
               }
            }
            name = s_colorMap[color.toString()] as String;
         }
         else
         {
            name = "clear";
         }
         return name;
      }
   }
}

