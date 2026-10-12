package Managers
{
   public class AssetHashManager
   {
      
      public static var masterData:Object;
      
      public static var deltaData:Object;
      
      public function AssetHashManager()
      {
         super();
      }
      
      public static function isUsingExternalHash() : Boolean
      {
         return AssetHashConfig.isUsingExternalHash;
      }
      
      public static function getAssetPath(path:String) : String
      {
         var category:String = null;
         var hashKey:String = null;
         var hashKeyPart:String = null;
         var hashExt:String = null;
         var assetHash:String = null;
         var assetHashRegEx:RegExp = /assets\/([a-z0-9_\-\%]+)\/(([a-z0-9_\-\%\/]+)\.([a-zA-Z0-9]{3}))/i;
         var matches:Object = assetHashRegEx.exec(path);
         var result:String = path;
         if(matches != null)
         {
            category = matches[1];
            hashKey = matches[2];
            hashKeyPart = matches[3];
            hashExt = matches[4];
            assetHash = "";
            if(deltaData.hasOwnProperty(category) && Boolean(deltaData[category].hasOwnProperty(hashKey)))
            {
               assetHash = deltaData[category][hashKey];
            }
            else if(masterData.hasOwnProperty(category) && Boolean(masterData[category].hasOwnProperty(hashKey)))
            {
               assetHash = masterData[category][hashKey];
            }
            else
            {
               result = path;
            }
            if(assetHash != "")
            {
               result = getFullAssetPath(category,hashKey,assetHash,hashKeyPart,hashExt);
            }
         }
         return result;
      }
      
      private static function getFullAssetPath(category:String, key:String, hash:String, hashKeyPart:String, extension:String) : String
      {
         var assetHashRegEx:RegExp = /((([a-z0-9_\-\%]+)\/)+)([a-z0-9_\-\%]+)\.[a-zA-Z0-9]{3}/i;
         var matches:Object = assetHashRegEx.exec(key);
         var assetKey:String = "";
         if(matches != null)
         {
            assetKey = matches[1];
         }
         return "assets/" + category + "/" + assetKey + hash + "." + extension;
      }
   }
}

