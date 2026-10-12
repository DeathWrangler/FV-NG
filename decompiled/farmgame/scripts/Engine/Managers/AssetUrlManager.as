package Engine.Managers
{
   public class AssetUrlManager
   {
      
      private static var m_instance:AssetUrlManager;
      
      protected var m_assetPrefix:String;
      
      protected var m_hashedPrefix:String;
      
      protected var m_index:Object;
      
      public function AssetUrlManager(param1:String, param2:String, param3:String)
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         super();
         GlobalEngine.assert(AssetUrlManager.m_instance == null,"Multiple AssetUrlManagers instantiated");
         AssetUrlManager.m_instance = this;
         this.m_assetPrefix = param1;
         this.m_hashedPrefix = param2;
         if(param3 != null)
         {
            this.m_index = new Object();
            _loc4_ = param3.replace(/(^\s*|\s*$)/,"").split("\n");
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               _loc5_ = _loc4_[_loc6_];
               _loc7_ = _loc5_.split(":",2);
               if(_loc7_.length == 2 && (_loc7_[1] as String).length > 0)
               {
                  this.m_index[_loc7_[1]] = _loc7_[0];
               }
               _loc6_++;
            }
         }
      }
      
      public static function get instance() : AssetUrlManager
      {
         GlobalEngine.assert(AssetUrlManager.m_instance != null,"AssetUrlManager not instantiated");
         return AssetUrlManager.m_instance;
      }
      
      public function lookUpUrl(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         if(this.m_index != null && param1.indexOf(this.m_assetPrefix) == 0)
         {
            _loc2_ = param1.substr(this.m_assetPrefix.length);
            if(this.m_index[_loc2_])
            {
               _loc3_ = param1.split(".");
               _loc4_ = "." + _loc3_[_loc3_.length - 1];
               return this.m_hashedPrefix + this.m_index[_loc2_] + _loc4_;
            }
            return param1;
         }
         return param1;
      }
   }
}

