class AddressEntity {
	String code;
	List<AddressEntity> children;
	String name;

	AddressEntity({this.code, this.children, this.name});

	AddressEntity.fromJson(Map<String, dynamic> json) {
		code = json['code'];
		if (json['children'] != null) {
			children = new List<AddressEntity>();(json['children'] as List).forEach((v) { children.add(new AddressEntity.fromJson(v)); });
		}
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['code'] = this.code;
		if (this.children != null) {
      data['children'] =  this.children.map((v) => v.toJson()).toList();
    }
		data['name'] = this.name;
		return data;
	}

	@override
	String toString() {
		return '$name';
	}

}

