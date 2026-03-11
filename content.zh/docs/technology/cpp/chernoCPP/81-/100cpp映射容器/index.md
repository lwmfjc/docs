---
title: 100cpp映射容器
description: 100cpp映射容器
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-11T16:22:01+08:00
lastmod: 2026-03-11T16:22:01+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 简介

## 什么是 Map？

- Map 是一种容器，用于存储==键值对==。它允许你通过一个“键”（Key）来快速查找对应的“值”（Value）。
- 类比：就像一本字典，单词是键，定义是值。

## std::map vs std::unordered\_map

- std::map (==有序==映射)：
    - 底层结构：红黑树（一种自平衡二叉搜索树）。
    - 特点：元素按键的顺序自动排序。
    - 复杂度：==查找、插入、删除均为 O(logn)==。
- std::unordered\_map (无序映射)：    
    - 底层结构：哈希表（Hash Table）。
    - 特点：==元素没有特定顺序==。
    - 复杂度：==平均情况下查找速度为 O(1)==，通常比 `std::map` 快，除非哈希冲突严重。

## 代码演示：基础用法

- 展示如何定义 `std::map<std::string, CityRecord>`。
- 使用 `operator[]` 进行赋值：`map["Berlin"] = CityRecord { ... };`。
- 注意：如果访问一个不存在的键，`operator[]` 会自动创建一个默认构造的对象并插入。

## 迭代与访问

- 演示如何使用 `for (auto& [key, value] : map)`（C++17 结构化绑定）遍历 Map。
- 解释了老式迭代器用法：`it->first` 是键，`it->second` 是值。

## 性能取舍与选择建议

- 优先选择 `std::unordered_map`：如果你只需要快速查找，不需要元素有序，那么无序映射通常性能更优。
- 选择 `std::map` 的场景：当你需要遍历时保持特定顺序，或者需要使用类似 `lower_bound` 的区间查找功能时。

## 复杂键的处理

- 讲解了如果使用自定义类作为键，`std::map` 需要该类重载 `<` 运算符，而 `std::unordered_map` 则需要提供哈希函数。

